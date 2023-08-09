# How to Generate a CSR in Linux

A Certificate Signing Request (CSR) is a request for a digital certificate from a certification authority (CA). It is typically created by a website owner or an individual seeking to obtain a digital certificate for secure communication over the internet.

A CSR consists of a public key and information about the applicant, such as the domain name, organization name, and location. The applicant generates the CSR and submits it to a CA, along with any required documentation. The CA then verifies the information in the CSR and, if everything is in order, creates a signed digital certificate that is issued to the applicant.

## Installing OpenSSL

Use one of the following commands to install the OpenSSL packages on your Redhat or Debian-based systems.

```
sudo dnf install openssl         ## Redhat based systems 
sudo apt install openssl         ## Debian based systems 
```

# Generate CSR in Linux
To generate a Certificate Signing Request (CSR) in Linux, you will need to have OpenSSL installed on your system. OpenSSL is an open-source implementation of the SSL and TLS protocols, and it is often used to create certificates and keys for secure communication over the internet.

To generate a CSR, follow these steps:

Open a terminal and navigate to the directory where you want to store the CSR and key files.

Run the following command to generate a private key:

```
openssl genrsa -out mykey.key 2048 
```

This will generate a 2048-bit RSA private key and store it in the file "mykey.key". You can specify a different key size by changing the value of 2048.

Run the following command to generate a CSR using the private key:

```
openssl req -new -key mykey.key -out mycsr.csr 
```

This command will prompt you to enter the following information:

Country Name (2 letter code): US

State or Province Name (full name): California

Locality Name (eg, city): California

Organization Name (eg, company): TecAdmin Inc

Organizational Unit Name (eg, section): Internet Advertisement

Common Name (eg, fully qualified domain name): www.example.com

Email Address: your_email@example.com

Enter the appropriate information for your certificate, and then press Enter to continue. When you are finished, the CSR will be stored in the file "mycsr.csr".

Submit the CSR to a certificate authority (CA) to obtain a signed certificate. The CA will use the CSR to create a certificate that is signed with the CA’s private key.

Once you have received the signed certificate from the CA, you can use it to secure your website or other applications.

Conclusion
The signed certificate is used to establish a secure connection between a website or application and a client, such as a web browser. It allows the client to verify the identity of the server and establish an encrypted connection.

In summary, CSR is a key step in the process of obtaining a digital certificate, which is used to secure communication over the internet. I hope this helps! Let me know if you have any questions.