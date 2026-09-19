import asyncio
import logging
import uvloop

# Install uvloop as the default event loop policy
asyncio.set_event_loop_policy(uvloop.EventLoopPolicy())

logging.basicConfig(level=logging.INFO, format='%(asctime)s - [Anti-DDoS] - %(message)s')

MAX_CONNECTIONS = 100
CHECK_INTERVAL = 10  # Seconds between checks

async def check_connections():
    try:
        cmd = "netstat -ntu | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -nr"
        
        # Asynchronously run shell pipeline without blocking the event loop
        proc = await asyncio.create_subprocess_shell(
            cmd,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE
        )
        
        stdout, stderr = await proc.communicate()
        
        if proc.returncode != 0:
            logging.error(f"Command failed with error: {stderr.decode('utf-8').strip()}")
            return

        lines = stdout.decode('utf-8').strip().split('\n')
        for line in lines:
            parts = line.strip().split()
            if len(parts) == 2:
                count, ip = int(parts[0]), parts[1]
                if count > MAX_CONNECTIONS and ip not in ['127.0.0.1', '0.0.0.0', '::1']:
                    logging.warning(f"High connection volume detected from {ip}: {count} connections.")

    except Exception as e:
        logging.error(f"Error checking connections: {e}")

async def main():
    logging.info("Anti-DDoS monitor started (asyncio + uvloop).")
    while True:
        await check_connections()
        await asyncio.sleep(CHECK_INTERVAL)

if __name__ == "__main__":
    asyncio.run(main())
