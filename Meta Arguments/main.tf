resource "aws_s3_bucket" "list_buckets" {
  count = length(var.bucket_name)
  bucket = var.bucket_name[count.index]
}

resource "aws_s3_bucket" "set_buckets" {
  for_each = var.bucket_name_set
  bucket = each.key
  # we can also use each.value here as for list and set both mean the same 

  # dependency
  depends_on = [ aws_s3_bucket.list_buckets ]
}

