import socket
import threading
import argparse
import time
from proxyscrape import create_collector, get_collector
import string
import random
import asyncio
from concurrent.futures import ThreadPoolExecutor

def generate_random_data(size):
    return ''.join(random.choices(string.ascii_letters + string.digits, k=size))

def get_proxy():
    # Use proxyscrape to fetch a new list of proxies
    collector = get_collector('default')
    proxy_list = collector.get_proxy({'protocol': 'socks5'})  # Adjust the protocol as needed
    return proxy_list

async def proxy_handler(target_host, target_port, client_socket, duration, continuous, payload_size):
    loop = asyncio.get_event_loop()
    with ThreadPoolExecutor() as executor:
        while True:
            # Fetch a new proxy list for each connection
            proxy = get_proxy()

            # Create a socket to connect to the target using the fetched proxy
            proxy_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

            try:
                proxy_socket.connect((proxy.host, proxy.port))
                print(f'[*] Connected to proxy: {proxy.host}:{proxy.port}')

                # Forward data between client and target
                start_time = time.time()
                while time.time() - start_time < duration:
                    data = generate_random_data(payload_size)  # Maximize data being sent
                    await loop.run_in_executor(executor, proxy_socket.send, data.encode())

                    proxy_response = proxy_socket.recv(4096)
                    client_socket.send(proxy_response)

            except Exception as e:
                print(f'[!] Error connecting to proxy: {e}')

            finally:
                # Close connections
                proxy_socket.close()
                client_socket.close()

                if not continuous:
                    break  # Break the loop if not in continuous mode

async def start_proxy_server(bind_host, bind_port, target_host, target_port, duration, continuous, payload_size):
    loop = asyncio.get_event_loop()
    server = await loop.create_server(
        lambda: asyncio.start_server(
            lambda client_reader, client_writer: asyncio.ensure_future(
                proxy_handler(target_host, target_port, client_writer, duration, continuous, payload_size)
            ),
            host=bind_host,
            port=bind_port
        ),
        bind_host,
        bind_port
    )
    async with server:
        print(f'[*] Listening on {bind_host}:{bind_port}')
        await server.serve_forever()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="TCP Proxy Server")
    parser.add_argument("--bind_host", default="127.0.0.1", help="Proxy server's listening IP")
    parser.add_argument("--bind_port", type=int, default=8888, help="Proxy server's listening port")
    parser.add_argument("--target_host", required=True, help="Target host")
    parser.add_argument("--target_port", type=int, required=True, help="Target port")
    parser.add_argument("--duration", type=int, default=60, help="Duration in seconds for proxy connections")
    parser.add_argument("--continuous", action="store_true", help="Connect and disconnect on repeat in a loop")
    parser.add_argument("--payload_size", type=int, default=4096, help="Size of the payload being sent")

    args = parser.parse_args()

    # Start the proxy server
    asyncio.run(start_proxy_server(args.bind_host, args.bind_port, args.target_host, args.target_port, args.duration, args.continuous, args.payload_size))
