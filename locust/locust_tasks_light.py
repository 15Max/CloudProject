import os
import random
from locust import HttpUser, task, between
from requests.auth import HTTPBasicAuth

class NextcloudUser(HttpUser):
    auth = None
    user_name = None
    wait_time = between(1, 3)

    def on_start(self): 
        user_idx = random.randint(1, 80)
        self.user_name = f'test_user{user_idx}'
        user_password = f'Test_password{user_idx}!'
        self.auth = HTTPBasicAuth(self.user_name, user_password)

    @task(2)
    def authentication(self):
        self.client.head("/remote.php/dav", auth=self.auth)

    @task(4)
    def search(self):
        response = self.client.request("PROPFIND", f"/remote.php/dav/files/{self.user_name}/", auth=self.auth)
        print(response.text)
    
    # Searches for the file Readme.md in the user's directory which is loaded by default in Nextcloud 
    @task(4)
    def read_file(self):
        self.client.get(f"/remote.php/dav/files/{self.user_name}/Readme.md", auth=self.auth, name="/remote.php/dav/files/[user]/Readme.txt")

    # Creates a small file and then deletes it
    @task(1)
    def delete_file(self):
        url = f"/remote.php/dav/files/{self.user_name}/Testfile.md"
        file_content = b"x"  # 1 byte
        self.client.put(url, data=file_content, auth=self.auth, name="/remote.php/dav/files/[user]/Testfile.md PUT")

        # Delete the newly created file
        self.client.delete(url, auth=self.auth, name="/remote.php/dav/files/[user]/Testfile.md DELETE")





