import os
import random
import time
from locust import HttpUser, task, between
from requests.auth import HTTPBasicAuth

class NextcloudUser(HttpUser):
    auth = None
    user_name = None
    uploaded_files = []
    wait_time = between(1, 2)

    def on_start(self): 
        user_idx = random.randint(1, 100)
        self.user_name = f'test_user{user_idx}'
        user_password = f'Test_password{user_idx}!'
        self.auth = HTTPBasicAuth(self.user_name, user_password)
        self.uploaded_files = []

    def on_stop(self):
        # Clean up uploaded files
        for remote_path in self.uploaded_files:
            try:
                self.client.delete(remote_path, auth=self.auth, name="DELETE /cleanup")
            except Exception as e:
                print(f"[CLEANUP ERROR] Failed to delete {remote_path}: {e}")

    @task(2)
    def authentication(self):
        self.client.head("/remote.php/dav", auth=self.auth)

    @task(3)
    def search(self):
        self.client.request(
            "PROPFIND",
            f"/remote.php/dav/files/{self.user_name}/",
            auth=self.auth,
            name="/remote.php/dav/files/[user]/ PROPFIND"
        )
    
    @task(3)
    def read_file(self):
        self.client.get(
            f"/remote.php/dav/files/{self.user_name}/Readme.md",
            auth=self.auth,
            name="/remote.php/dav/files/[user]/Readme.md"
        )

    @task(1)
    def delete_file(self):
        file_id = random.randint(0, 100000)
        file_name = f"Testfile_{file_id}.md"
        url = f"/remote.php/dav/files/{self.user_name}/{file_name}"
        file_content = b"x"  # 1 byte
        time.sleep(0.2)

        self.client.put(url, data=file_content, auth=self.auth, name="PUT /upload")
        self.client.delete(url, auth=self.auth, name="/remote.php/dav/files/[user]/Testfile.md DELETE")

    @task(8)
    def load_file_1kb(self):
        file_path = self._ensure_file_exists("file1KB", size_kb=1)
        rand_id = random.randint(0, 999999)
        remote_path = f"/remote.php/dav/files/{self.user_name}/file1KB_{rand_id}"
        with open(file_path, "rb") as file:
            self.client.put(remote_path, data=file, auth=self.auth, name="PUT /upload")
        self.uploaded_files.append(remote_path)

    @task(4)
    def load_file_1mb(self):
        file_path = self._ensure_file_exists("file1MB", size_kb=1024)
        rand_id = random.randint(0, 999999)
        remote_path = f"/remote.php/dav/files/{self.user_name}/file1MB_{rand_id}"
        with open(file_path, "rb") as file:
            self.client.put(remote_path, data=file, auth=self.auth, name="PUT /upload")
        self.uploaded_files.append(remote_path)


    def _ensure_file_exists(self, name, size_kb):
            base_path = os.path.dirname(__file__)
            file_path = os.path.join(base_path, "..", "test_files", name)

            if not os.path.exists(file_path):
                os.makedirs(os.path.dirname(file_path), exist_ok=True)
                with open(file_path, "wb") as f:
                    f.write(b"x" * 1024 * size_kb)

            return file_path







