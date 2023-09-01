### Linux

We are creating Linux servers in AWS Cloud. Don't create servers in your laptops that consume lot of memory. Use free trail of AWS account.

**NOTE: Delete EC2 after practice**

Make sure your security group has access to port number 22.

Once you create the server, you need to use ssh command to login to the server.

```
ssh -i <path-to-pem-file> username@IP-Adress
```

$ - denotes normal user <br/>
\# - denotes root user






# Daily Use Linux Commands

# File and Directory Manipulation

ls: List files and directories in the current directory.

```
ls
```

ls -l: List files and directories with detailed information.

```
ls -l
```

cd: Change the current directory.

```
cd directory_name
```

pwd: Display the current working directory.

```
pwd
```

mkdir: Create a new directory or create a directory in inside sub directory

```
mkdir directory_name
mkdir -p directory_name/subdirectory_name/directory_name
```

touch: Create an empty file.

```
touch file_name
```

cp: Copy files or directories.

```
cp source destination
```

mv: Move or rename files or directories.

```
mv old_name new_name
```

To remove any file. -f means forcefully

```
rm -f [file-name]
```

To remove entire folder. -r means recursive. -f means forcefully

```
rm -rf [folder-name]
```

find text in a file

```
grep [text-to-search] [file-name]
```

find file in a root level

```
find / -name [file-name]
```

find directory in a root level

```
find / -type d -name [dir-name]
```

top 10 lines in a file.

```
head [file-name]
```

last 10 lines in a files

```
tail [file-name]
```

custom number of lines

```
head -n 5 [file-name]
```

# Text Manipulation

* Create the file and open it to enter text. Enter the text and press ctrl+d to save.

```
cat > [file-name]
```

* Append the text to the file.

```
cat >> [file-name]
```

cat: Display the contents of a file.

```
cat file_name
```

grep: Search for a pattern in files.

```
grep pattern file_name
```

sed: Stream editor for text manipulation.

```
sed 's/old_text/new_text/g' file_name
```

awk: Text processing tool for extracting data.

```
awk '{print $1}' file_name
```

# File Compression

tar: Create or extract tar archives.

```
tar -cvf archive.tar files_to_archive
tar -xvf archive.tar
```

gzip: Compress or decompress files using gzip.

```
gzip file_name
gzip -d compressed_file.gz
```

zip: Create or extract zip archives.

```
zip archive.zip files_to_archive
unzip archive.zip
```

# Network and Internet

ping: Test network connectivity to a host.

```
ping host_or_ip
```

curl: Download files from the internet or Display the content in a file

```
curl -o output_file URL
curl URL
```

wget: Download files from the internet.

```
wget URL
```

netstat: Display network connections and listening ports.

```
netstat -tuln
```

telnet: Connect to remote hosts using the Telnet protocol.

```
telnet host_or_ip port
```

# System Information

uname: Display system information.

```
uname -a
```

df: Display disk space usage.

```
df -h
```

du: Display disk usage of files and directories.

```
du -h file_or_directory
```

free: Display system memory usage.

```
free -h
```


# Package Management

apt: Package management for Debian-based systems.

```
sudo apt update
sudo apt install package_name
```

yum: Package management for Red Hat-based systems.

```
sudo yum update
sudo yum install package_name
```

dnf: Modern package manager for Fedora-based systems.

```
sudo dnf update
sudo dnf install package_name
```

# Permissions

sudo: Execute commands with superuser privileges.

```
sudo command
```

su: Switch to another user or become superuser.

```
su - username
```


# File Permissions

chmod: Change file permissions.

```
chmod permissions file_name
```

chown: Change file owner and group.

```
chown user:group file_name
```


# Process Management

ps: Display information about active processes.

```
ps aux
```

kill: Terminate processes by their PID or name.

```
kill process_id
```

top: Display dynamic overview of system processes.

```
top
```

pkill: Terminate processes by their name.

```
pkill process_name
```

nohup: Run a command that keeps running after logout.

```
nohup command &
```

# User Management

useradd: Create a new user account.

```
sudo useradd username
```

passwd: Change a user's password.

```
sudo passwd username
```

usermod: Modify user account properties.

```
sudo usermod -aG group_name username
```

groupadd: Create a new user group.

```
sudo groupadd group_name
```

# Text Editors

nano: Simple command-line text editor.

```
nano file_name
```


vim: Advanced text editor.

```
vim file_name
```

echo: Print text or variables to the terminal.

```
echo "Hello, World!"
```