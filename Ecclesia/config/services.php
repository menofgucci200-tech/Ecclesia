<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Third Party Services
    |--------------------------------------------------------------------------
    |
    | This file is for storing the credentials for third party services such
    | as Mailgun, Postmark, AWS and more. This file provides the de facto
    | location for this type of information, allowing packages to have
    | a conventional file to locate the various service credentials.
    |
    */

    'postmark' => [
        'key' => env('POSTMARK_API_KEY'),
    ],

    'resend' => [
        'key' => env('RESEND_API_KEY'),
    ],

    'ses' => [
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
    ],

    'slack' => [
        'notifications' => [
            'bot_user_oauth_token' => env('SLACK_BOT_USER_OAUTH_TOKEN'),
            'channel' => env('SLACK_BOT_USER_DEFAULT_CHANNEL'),
        ],
    ],

    // CinetPay — Mobile Money & card payments (Orange, MTN, Moov, Wave, Visa).
    // The module runs in a graceful "not configured" state until these are set.
    'cinetpay' => [
        'site_id' => env('CINETPAY_SITE_ID'),
        'api_key' => env('CINETPAY_API_KEY'),
        'secret_key' => env('CINETPAY_SECRET_KEY'),
        'currency' => env('CINETPAY_CURRENCY', 'XOF'),
        'base_url' => env('CINETPAY_BASE_URL', 'https://api-checkout.cinetpay.com/v2'),
        // Where the user lands after paying (a lightweight page that tells the
        // app to poll the payment status).
        'return_url' => env('CINETPAY_RETURN_URL', env('APP_URL').'/api/payments/cinetpay/return'),
    ],

];
