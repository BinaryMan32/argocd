# system-upgrade

Automatic kubernetes upgrades

See https://docs.k3s.io/upgrades/automated

The deployment generates the plan CRD, so it needs to be deployed before doing a
full sync to create the server and agent plans.
