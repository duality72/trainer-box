trainer-box
===========

A simple vagrant build for TW infrastructure trainers

I have a pre-built Vagrant box for use by ThoughtWorkers. It's 500 MB, though, so check My ThoughtWorks for where it ends up being uploaded.

Building the box (optional)
---------------------------
This build just requires Ant and Vagrant. Run 'ant build' and a lucid32 box will be downloaded, started up in Vagrant, and have the necessary Puppet scripts applied. The built box will have the necessary SES and Cloud Formation tools installed plus the lab-stack repo cloned from GitHub.

