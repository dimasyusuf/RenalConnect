<?php
	#PLEASE PROVIDE YOUR EMAIL SENDER KEY BELOW, WHICH WILL UNLOCK THE SEND CAPABILITY
	#THIS SHOULD BE THE SAME AS YOUR email_sender_key VARIABLE IN io.pm
	$correct_key = "";

	$to = $_REQUEST["to"];
	$from = $_REQUEST["from"];
	$subject = "RenalConnect - " . $_REQUEST["subject"];
	$cc = $_REQUEST["cc"];
	$bcc = $_REQUEST["bcc"];
	$key = $_REQUEST["key"];
	$body = $_REQUEST["body"] . "\n\nSent by RenalConnect\n\nUnless otherwise indicated, this message is intended only for the personal and confidential use of the designated recipient named above. If you are not the intended recipient of this message you are hereby notified that any review, dissemination, distribution or copying of this message is strictly prohibited.\n\nSauf indication contraire, ce message est uniquement destiné à l'usage personnel et confidentiel du destinataire désigné nommé ci-dessus. Si vous n'êtes pas le destinataire de ce message, vous êtes avisé que toute révision, diffusion, distribution ou copie de ce message est strictement interdite.\n\nA menos que se indique lo contrario, este mensaje está destinado sólo para el uso personal y confidencial del destinatario designado nombrado arriba. Si usted no es el destinatario original de este mensaje se le notifica que cualquier revisión, difusión, distribución o copia de este mensaje está estrictamente prohibida.";
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
