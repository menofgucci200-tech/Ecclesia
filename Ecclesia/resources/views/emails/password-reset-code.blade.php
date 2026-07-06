<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Réinitialisation de mot de passe</title>
</head>
<body style="margin:0;padding:0;background-color:#f4f6f9;font-family:Arial,Helvetica,sans-serif;color:#1f2a44;">
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="padding:32px 0;">
        <tr>
            <td align="center">
                <table role="presentation" width="480" cellpadding="0" cellspacing="0" style="background:#ffffff;border-radius:16px;overflow:hidden;">
                    <tr>
                        <td style="background:#16335b;padding:24px;text-align:center;">
                            <span style="color:#c6a02c;font-size:22px;font-weight:bold;letter-spacing:2px;">ECCLESIA</span>
                        </td>
                    </tr>
                    <tr>
                        <td style="padding:32px;">
                            <p style="font-size:16px;margin:0 0 16px;">Cher(e) {{ $firstName }},</p>
                            <p style="font-size:15px;line-height:1.6;margin:0 0 24px;color:#4b5563;">
                                Vous avez demandé la réinitialisation de votre mot de passe. Utilisez le code
                                ci-dessous pour continuer. Ce code expire dans {{ $expiresInMinutes }} minutes.
                            </p>
                            <div style="text-align:center;margin:24px 0;">
                                <span style="display:inline-block;background:#f4f6f9;border:1px solid #e2e8f0;border-radius:12px;padding:16px 28px;font-size:32px;font-weight:bold;letter-spacing:8px;color:#16335b;">
                                    {{ $code }}
                                </span>
                            </div>
                            <p style="font-size:13px;line-height:1.6;margin:24px 0 0;color:#9ca3af;">
                                Si vous n'êtes pas à l'origine de cette demande, ignorez cet e-mail : votre mot de passe restera inchangé.
                            </p>
                        </td>
                    </tr>
                    <tr>
                        <td style="background:#f4f6f9;padding:16px;text-align:center;font-size:12px;color:#9ca3af;">
                            Ecclesia — Le numérique au service de la mission.
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
