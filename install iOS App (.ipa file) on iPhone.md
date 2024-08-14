# install iOS App (.ipa file) on iPhone
If you have a Provisioning Profile in Xcode then below method will 100% work as it works for me :

1. Create Archive

1. Right-Click on the Archive and Click Show in Finder.

1. You can see .xcarchive file in Finder.

1. Right CLick on the .xcarchive file and click Show package content and go to the Products -> Applications folder. 

1. Inside Applications folder Create a new folder name it **Payload** and drag the `.app` file into that folder.

1. Compress [Create Zip File] the Payload folder and rename it to whatever you want and change the extension to `.ipa`.

1. Open 3uTools, connect your iPhone then go to Applications on 3uTools and press on **import and install** then selected the `.ipa `file.

# Reference
- [StackOverflow](https://stackoverflow.com/a/72724017/15838088)
- [Install .ipa file in Unjailbroken iPhone](https://www.3u.com/news/articles/1505/how-to-install-ipa-file-in-iphone-using-3utools)
