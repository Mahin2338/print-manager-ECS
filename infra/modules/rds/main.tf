resource "aws_db_subnet_group" "main" {
  name = "print-manager"
  subnet_ids = var.private_subnet_ids
}



resource "aws_db_instance" "main" {
identifier             = "print-manager-db"
allocated_storage      = 20
storage_type           = "gp3"
engine                 = "postgres"
engine_version         = "15"
instance_class         = "db.t3.micro"
db_name                = "printmanager"
username               = "print"
password               = var.db_password


db_subnet_group_name   = aws_db_subnet_group.main.name
vpc_security_group_ids = [var.rds_sg_id]
publicly_accessible    = false



backup_retention_period = 7
backup_window          = "03:00-04:00"
maintenance_window     = "Mon:04:00-Mon:05:00"



skip_final_snapshot    = true  
deletion_protection    = false 



storage_encrypted      = true

tags = {
Name        = "Print Manager Database"
Environment = "dev"
}
}