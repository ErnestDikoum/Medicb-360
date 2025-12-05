<?php
use App\Http\Controllers\ProduitController;

Route::apiResource('produits', ProduitController::class);

Route::middleware('api')->group(function () {
    Route::get('/produits', [ProduitController::class, 'index']);
    Route::post('/produits', [ProduitController::class, 'store']);
    Route::put('/produits/{id}', [ProduitController::class, 'update']);
    Route::delete('/produits/{id}', [ProduitController::class, 'destroy']);
    Route::get('/ping', function () {
    return response()->json(['status' => 'ok']);
});
