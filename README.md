# ToDo

1. verify instances in public network can ssh in, http/s out [done]
2. verify https/s to instance in private network works [done]
3. verify http/s out of private network works [done]
4. instance connect / session manager to instances [done]
6. push module to github [done]
7. test frameork using module pulled from github
8. document, including diagram similar to https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html
9. readme in the example code



we need to include some AWS addresses for SSH in. These are obtained by

```
wget https://ip-ranges.amazonaws.com/ip-ranges.json
jq '.prefixes[] | select(.service=="EC2_INSTANCE_CONNECT")' < ip-ranges.json
```

instance connect can be controlled through IAM policies, see https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-connect-set-up.html


also for the awesomeness of instance connect, don't have to provision a key on in the instance, and from my desktop can do

```
 mssh -u adm_rhook_cli  i-0b619e1685a0d4742
 ```
