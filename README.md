# s3scp
## Serverless S3 copy to remote host via SCP.

You have a legacy app that you can't/don't want to touch that expects PDFs to be manually uploaded into a document inbox.
You have a virtual fax/scan workflow that automatically saves PDFs into s3.

This solution automatically saves a copy of the PDFs into the legacy app's inbox via a lambda triggered on a schedule.  The lambda will transfer the newly created PDF objects in S3 to the file directory of the legacy app's inbox on the remote host via 'scp'.

Successfully transferred objects are renamed from the /inbound to the /received folder in the S3 bucket.  If the scp fails, an error message is generated and the PDF will remain in the /inbound folder.  The next schedule event will reattempt the transfer.
