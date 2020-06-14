/*README:
https://www.terraform.io/docs/configuration/expressions.html
https://www.hashicorp.com/blog/terraform-0-1-2-preview/
path.module is the filesystem path of the module where the expression is placed.
path.root is the filesystem path of the root module of the configuration.
path.cwd is the filesystem path of the current working directory. In normal use of Terraform this is the same as path.root, but some advanced uses of Terraform run it from a directory other than the root module directory, causing these paths to be different
Strings are usually represented by a double-quoted
Numbers are represented by unquoted sequences of digits with or without a decimal point
Lists/tuples are represented by a pair of square brackets containing a comma-separated sequence of values, like ["a", 15, true] 
count.index, in resources that use the count meta-argument.
each.key / each.value, in resources that use the for_each meta-argument.
self, in provisioner and connection blocks.
A local value assigns a name to an expression, allowing it to be used multiple times within a module without repeating it.
*/

provider "akamai" {
    edgerc = "~/.edgerc" 
}   

#Example of how csvdecode
/*
> csvdecode("a,b,c\n1,2,3\n4,5,6")
[
  {
    "a" = 1
    "b" = 2
    "c" = 3
  },
  {
    "a" = 4
    "b" = 5
    "c" = 6
  }
]
*/

locals {
  #dns_records = csvdecode(file(path.module/dns_records.csv))
  #csv_dns = file("./dns_records.csv")
  dns_records = csvdecode(file("./dns_records_new.csv"))
}

#How Count length works
/*
> length({
    "a" = "b"
    })
1
*/

resource "akamai_dns_record" "www" {
    count = length(local.dns_records)
    zone = local.dns_records[count.index].zone
    name = local.dns_records[count.index].name
    recordtype = "CNAME"
    active = true
    ttl = local.dns_records[count.index].ttl
    target = [local.dns_records[count.index].target]
}   

/*
resource "akamai_dns_record" "www" {
    #count = length(local.dns_records)
    zone = "rajathtest.com"
    name = "abc.rajathtest.com"
    recordtype = "CNAME"
    active = true
    ttl = 300
    target = ["abc.cde.rajathtest.com"]
} 
*/