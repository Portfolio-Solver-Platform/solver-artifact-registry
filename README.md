# solver-artifact-registry
artifact registry for minizinc solvers


## How to run it

There are two ways you can run this
- `skaffold dev`: this will start the project, but it will not configure harbor. You will thereafter manually call terraform (when harbor has been fully deployed) to configure harbor. With this approach you will get the logs from skaffold dev
- `make dev` or `make prod`: This will automatically also apply terraform after it has deployed harbor, however no error logs will be seen from the terminal



