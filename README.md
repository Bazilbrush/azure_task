I took the liberty to create a deployment pipeline (it was easier to test this way) that splits out the separate environments in separate stages.
Having separate stages can ensure a deployment can go through quality gates before production infra is amended. 

 each VM is provisioned in a dedicated resource group. X
 each VM only allows incoming traffic from SSH. Outbound of DNS, HTTP, HTTPS X
 There is some form of backup strategy implemented. x
 the resources are protected from accidental deletion. x


"We expect you to demonstrate your ability to use nested data structures, therefore make sure you have
a root-level resource and a number of nested resources (and no dynamic blocks). " - Does wrapping things in a module count?


Things that can be improved:

1. naming convetion
2. tidy up the tagging as it's not present in cases
3. some resources could be shared (depends on the purpose of this deployment) 
4. sort out the networking and the IP ranges, maybe the user should be able to set them
5. module should export the IPs of the instances for interop with ansible or other provisioning tools
6. user set vm image
