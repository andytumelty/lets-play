Testing routing all outbound traffic from a public and private subnet through
a NAT instance that has squid proxy setup to filter http traffic.

Private subnets work as expected, for public inbound packets hit the hosts
directly but are directed via the NAT instance on return, meaning they're
dropped as the instance has no visibility of the initiated connection. 

Separate things to think about:
- Resilience?
- What is the maximum network throughput for the NAT instance? does this need
  to be in an ASG for when the network is being throttled?
