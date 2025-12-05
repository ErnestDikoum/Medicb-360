<?php

return [


    'paths' => ['api/*', 'sanctum/csrf-cookie'],

   

    'allowed_origins' => ['http://localhost:3000'],['https://medic-360.netlify.app/'],

    'allowed_methods' => ['*'],

    'allowed_headers' => ['*'],

    'supports_credentials' => true,


];
