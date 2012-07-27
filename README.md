trainer-box
===========

A simple vagrant build for TW infrastructure trainers

Building this box takes care of *most* of the setup that is required at the link below.

https://github.com/ThoughtWorksInc/InfraTraining

Once the box has been brought up or built, these are the additional configuration steps required.

1. You'll need to copy your certificate and private key you use with AWS to /home/vagrant/.ec2 on the VM via the share folder. Copy your files to /tmp (or C:\temp on Windows) on your host system, then ssh to the VM and copy the files from ~/share to ~/.ec2. You can rename them from their long names to cert.pem and pk.pem or update the EC2_PRIVATE_KEY and EC2_CERT environment variables in ~/.bash_profile.
2. Uncomment SES_FROM_EMAIL in .bash_profile and enter your email address for the value. After you save, run 'source .bash_profile' to update your environment.
3. Edit the .ec2/access.pl file and enter your AWSAccessKeyId and AWSSecretKey.

This should allow going through the InfraTraining preparation steps (ses-verify-identity and running lab_stack.sh) without any software installation needed.

I have a pre-built Vagrant box for use by ThoughtWorkers. It's 500 MB, though, so check My ThoughtWorks for where it ends up being uploaded.

Building the box (optional)
---------------------------
This build just requires Ant and Vagrant. Run 'ant build' and a lucid32 box will be downloaded, started up in Vagrant, and have the necessary Puppet scripts applied. The built box will have the necessary SES and Cloud Formation tools installed plus the lab-stack repo cloned from GitHub.

