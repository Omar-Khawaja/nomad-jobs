# Please do not use this for any serious workloads. This is a sample job that
# will deploy postgres, populate it with some data, change the passwords for
# the users (to whatever you specify below), and then lock down the database by
# changing the authentication method in /var/lib/postgresql/data/pg_hba.conf
# from trust to md5. 

# Please note that initdb scripts placed in /docker-entrypoint-initdb.d are
# executed in alphabetal order of file names.

job "database" {
  datacenters = ["dc1"]

  group "db" {

    task "server" {
      driver = "docker"

      config {
        image = "postgres"

        port_map {
          db = 5432
        }

        volumes = [
          "local:/docker-entrypoint-initdb.d/"
        ]
      }

      template {
        data = <<EOF
ALTER USER postgres WITH ENCRYPTED PASSWORD '<password>';
CREATE USER user1 WITH ENCRYPTED PASSWORD '<password>';
CREATE DATABASE population;
\c population
CREATE TABLE people (
firstname varchar(255),
lastname varchar(255)
);
REVOKE ALL ON DATABASE population FROM user1;
EOF
        destination = "local/setup.sql"
      }

      template {
        data = <<EOF
sed -i '/^#/! s/trust/md5/g' /var/lib/postgresql/data/pg_hba.conf
EOF
        destination = "local/x-setup.sh"
      }

      resources {
        network {
          mbits = 10
          port  "db"{
	    static = 5432
	  }
        }
      }

      service {
        name = "database"
        port = "db"

        check {
          type     = "tcp"
          interval = "2s"
          timeout  = "2s"
        }
      }
    }
  }
}
