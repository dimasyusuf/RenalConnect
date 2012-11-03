<?php
	#PLEASE PROVIDE YOUR EMAIL SENDER KEY BELOW, WHICH WILL UNLOCK THE SEND CAPABILITY
	#THIS SHOULD BE THE SAME AS YOUR email_sender_key VARIABLE IN io.pm
	$correct_key = "d34cb047bb9757b2eb69128c1ed36013";

	$to = $_REQUEST["to"];
	$from = $_REQUEST["from"];
	$subject = "RenalConnect - " . $_REQUEST["subject"];
	$cc = $_REQUEST["cc"];
	$bcc = $_REQUEST["bcc"];
	$key = $_REQUEST["key"];
	$body = $_REQUEST["body"] . "\n\nSent by RenalConnect\n\nUnless otherwise indicated, this message is intended only for the personal and confidential use of the designated recipient(s) named above. If you are not the intended recipient of this message you are hereby notified that any review, dissemination, distribution or copying of this message is strictly prohibited.";
	if ($to != "" and $subject != "" and $key == $correct_key) {
 		$headers  = 'MIME-Version: 1.0' . "\r\n";
		$headers .= 'Content-type: text/plain; charset=iso-8859-1' . "\r\n";
		$headers .= "From: $from" . "\r\n";
		$headers .= "Bcc: $bcc" . "\r\n";
		if (mail($to, $subject, $body, $headers)) {echo "1";} else {echo "0";}
	} else {
	    echo "0";
	}
?>
