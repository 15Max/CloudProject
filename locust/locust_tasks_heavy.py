import os
import random
import time
from locust import HttpUser, task, between
from requests.auth import HTTPBasicAuth

class NextcloudUser(HttpUser):
    auth = None
    user_name = None
    wait_time = between(3,5)

    def on_start(self): 
        user_idx = random.randint(1, 100)
        self.user_name = f'test_user{user_idx}'
        user_password = f'Test_password{user_idx}!'
        self.auth = HTTPBasicAuth(self.user_name, user_password)

    @task(2)
    def authentication(self):
        self.client.head("/remote.php/dav", auth=self.auth)

    @task(4)
    def search(self):
        self.client.request(
            "PROPFIND",
            f"/remote.php/dav/files/{self.user_name}/",
            auth=self.auth,
            name="/remote.php/dav/files/[user]/ PROPFIND"
        )
    
    # Searches for the file Readme.md in the user's directory which is loaded by default in Nextcloud 
    @task(4)
    def read_file(self):
        self.client.get(f"/remote.php/dav/files/{self.user_name}/Readme.md", auth=self.auth, name="/remote.php/dav/files/[user]/Readme.md")

    # Creates a small file and then deletes it
    @task(1)
    def delete_file(self):
        url = f"/remote.php/dav/files/{self.user_name}/Testfile.md"
        file_content = b"x"  # 1 byte
        self.client.put(url, data=file_content, auth=self.auth, name="/remote.php/dav/files/[user]/Testfile.md PUT")
        time.sleep(0.2) # simulate a short delay
        # Delete the newly created file
        self.client.delete(url, auth=self.auth, name="/remote.php/dav/files/[user]/Testfile.md DELETE")

    @task(4)
    def load_file_1kb(self):
        base_path = os.path.dirname(__file__)
        file_path = os.path.join(base_path, "..", "test_files", "file1KB")

        # Ensure file exists (create 1KB if not)
        if not os.path.exists(file_path):
            os.makedirs(os.path.dirname(file_path), exist_ok=True)
            with open(file_path, "wb") as f:
                f.write(b"x" * 1024)  # 1KB of dummy data

        remote_path = f"/remote.php/dav/files/{self.user_name}/file1KB"
        with open(file_path, "rb") as file:
            self.client.put(remote_path, data=file, auth=self.auth, name="/remote.php/dav/files/[user]/file1KB")


    @task(4)
    def load_file_1mb(self):
        base_path = os.path.dirname(__file__)
        file_path = os.path.join(base_path, "..", "test_files", "file1MB")

        # Ensure file exists (create 1MB if not)
        if not os.path.exists(file_path):
            os.makedirs(os.path.dirname(file_path), exist_ok=True)
            with open(file_path, "wb") as f:
                f.write(b"x" * 1024 * 1024)  # 1MB of dummy data

        remote_path = f"/remote.php/dav/files/{self.user_name}/file1MB"
        with open(file_path, "rb") as file:
            self.client.put(remote_path, data=file, auth=self.auth, name="/remote.php/dav/files/[user]/file1MB")


    @task(2)
    def load_file_1GB(self):
        base_path = os.path.dirname(__file__)
        file_path = os.path.join(base_path, "..", "test_files", "file1GB")

        # Ensure file exists (create 1GB if not)
        if not os.path.exists(file_path):
            os.makedirs(os.path.dirname(file_path), exist_ok=True)
            with open(file_path, "wb") as f:
                f.write(b"x" * 1024 * 1024 * 1024)  # 1GB of dummy data

        remote_path = f"/remote.php/dav/files/{self.user_name}/file1GB"
        with open(file_path, "rb") as file:
            self.client.put(remote_path, data=file, auth=self.auth, name="/remote.php/dav/files/[user]/file1GB")

