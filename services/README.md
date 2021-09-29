# Services

## Kubernetes Dashboard

1. In a terminal, run
   ```
   $ kubectl proxy
   Starting to serve on 127.0.0.1:8001
   ```
2. Connect to the proxied dashboard
   http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:https/proxy/
3. Create cluster role binding and get token as described in:
   https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md
