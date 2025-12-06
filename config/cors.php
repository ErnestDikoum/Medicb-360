<?php

return [


    'paths' => ['api/*', 'sanctum/csrf-cookie'],
   

    'allowed_origins' => ['https://medic-360.netlify.app'], // ton frontend

    'allowed_methods' => ['*'],

    'allowed_headers' => ['*'],

    'supports_credentials' => false,


];
