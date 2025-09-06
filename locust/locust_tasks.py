import random
from locust import HttpUser,  task, between
from requests.auth import HTTPBasicAuth