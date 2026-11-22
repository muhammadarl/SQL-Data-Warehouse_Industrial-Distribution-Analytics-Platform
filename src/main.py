import config

if __name__ == "__main__":
    print(f"db: {config.POSTGRES_DATABASE}")
    print(f"username: {config.POSTGRES_USERNAME}")
    print(f"host: {config.POSTGRES_HOST}")
    print(f"port: {config.POSTGRES_PORT}")
