import argparse
from bs4 import BeautifulSoup
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from ipaddress import IPv4Address, ip_address
from urllib.parse import urljoin
import gnupg
from multiprocessing import Process, Pipe
import os.path
import platform
import requests
import socket
import subprocess
import tempfile
from typing import Tuple, List


def get_arch():
    machine = platform.machine().lower()
    if machine == 'arm64':
        return 'arm64'
    elif machine == 'x86_64' or machine == 'amd64':
        return 'amd64'
    else:
        raise RuntimeError(f"Could not determine a supported architecture (arm64 or amd64) from platform string: {machine}")

def get_gpg_signed_file(url):
    gpg = gnupg.GPG()
    with open("kali-key.asc") as key_f:
        import_result = gpg.import_keys(key_f.read())
    assert(import_result.count == 1)

    sig_req = requests.get(f"{url}.gpg")
    sig_req.raise_for_status()

    file_req = requests.get(url)
    file_req.raise_for_status()
    
    with tempfile.NamedTemporaryFile() as sig_f:
        sig_f.write(sig_req.text.encode())
        # We need to flush writes to the file before the signature can be verified
        sig_f.flush()
        verif_result = gpg.verify_data(sig_f.name, file_req.text.encode())
    
    assert(verif_result.valid)
    return file_req.text

def get_latest_kali_url_and_checksum(arch: str) -> Tuple[str, str]:
    """
    Given an architecture (e.g. arm64, amd64) returns the url to the latest kali ISO for that architecture and the ISO's checksum.
    """
    KALI_ISO_BASE_URL = "https://cdimage.kali.org/kali-images/current/"
    KALI_CHECKSUMS_FILE = "SHA256SUMS"

    images_req = requests.get(KALI_ISO_BASE_URL)
    images_req.raise_for_status()
    soup = BeautifulSoup(images_req.text, 'html.parser')
    images = [link.get('href') for link in soup.find_all('a') if link.get('href').endswith('.iso')]

    arch_image = [image for image in images if image.endswith(f"installer-{arch}.iso")]
    assert(len(arch_image) == 1)
    arch_image = arch_image[0]

    checksums_data = get_gpg_signed_file(urljoin(KALI_ISO_BASE_URL, KALI_CHECKSUMS_FILE))
    checksum_lines = checksums_data.split("\n")
    # The checksum file contains lines with one checksum per line in the format: "<checksum> <filename>"
    checksum = [line.split()[0] for line in checksum_lines if line.endswith(arch_image)]
    assert(len(checksum) == 1)
    checksum = checksum[0]

    return (
        urljoin(KALI_ISO_BASE_URL, arch_image),
        f"sha256:{checksum}",
    )

def get_private_ips() -> List[IPv4Address]:
    """
    Helper function to get all private IPv4 addresses for a machine (excluding loopback addresses)
    """
    addrs = socket.getaddrinfo(socket.gethostname(), None)
    ips = set([ip_address(a[4][0]) for a in addrs])
    private_ips = [
        ip for ip in ips
        if ip.version == 4
        and ip.is_private
        and not ip.is_loopback
    ]
    return private_ips

def host_preseed(conn):
    """
    Hosts the preseed file by spinning up an HTTP server that hosts the http directory.
    """
    private_ips = get_private_ips()
    host = private_ips[0].exploded
    port = 0
    parent_dir = os.path.dirname(os.path.realpath(__file__))
    preseed_dir = os.path.join(parent_dir, "http")

    class PreseedRequestHandler(SimpleHTTPRequestHandler):
        def __init__(self, request, client_address, server, directory=None) -> None:
            # Only serve files from the preseed directory (http)
            super().__init__(request, client_address, server, directory=preseed_dir)

    with ThreadingHTTPServer((host, port), PreseedRequestHandler) as httpd:
        host, port = httpd.socket.getsockname()[:2]
        # Send the host and port to the parent process
        conn.send((host, port))
        conn.close()
        httpd.serve_forever()

def pack_kali(kali_iso_url, kali_iso_checksum, preseed_host, preseed_port, arch):
    parent_dir = os.path.dirname(os.path.realpath(__file__))
    packer_template = os.path.join(parent_dir, "kali-vagrant.pkr.hcl")
    cmd = [
        "packer", "build",
        "-var", f"kali_iso_url={kali_iso_url}",
        "-var", f"kali_iso_checksum={kali_iso_checksum}",
        "-var", f"preseed_host={preseed_host}",
        "-var", f"preseed_port={preseed_port}",
        "-var", f"arch={arch}",
        packer_template
    ]
    print(f'Running command: {" ".join(cmd)}')
    with subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, bufsize=1, universal_newlines=True) as p:
        for line in p.stdout:
            print(line, end='')
        
        if p.returncode is None:
            p.wait(5)

        if p.returncode != 0:
            raise RuntimeError(f"Non-zero return code from process: {p.returncode}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Gets the latest kali ISO and builds a base vagrant image using packer.")
    parser.add_argument("--arch", choices=["arm64", "amd64"], default="arm64")

    args = parser.parse_args()

    arch = get_arch()

    iso_url, checksum = get_latest_kali_url_and_checksum(args.arch)

    parent_conn, child_conn = Pipe()
    preseed_proc = Process(target=host_preseed, args=(child_conn,))
    preseed_proc.start()
    try:
        preseed_host, preseed_port = parent_conn.recv()
        # Now that we have the preseed host running and the latest iso_url and checksum, we can finally run packer
        pack_kali(iso_url, checksum, preseed_host, preseed_port, arch)
    finally:
        parent_conn.close()

        preseed_proc.terminate()
        preseed_proc.join(5)
        preseed_proc.close()



    
