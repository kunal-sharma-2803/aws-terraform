locals {
  users = csvdecode(file("users.csv"))
  # this returns a list of maps 
}

