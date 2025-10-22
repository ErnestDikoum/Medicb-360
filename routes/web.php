<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ProduitController;

Route::prefix('api')->group(function () {
    Route::apiResource('produits', ProduitController::class);
});


Route::get('/', function () {
    return view('welcome');
});

