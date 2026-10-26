<?php
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\{ResourceController, EdgePushController, MobileAuthController};

Route::prefix('v1')->group(function () {
    Route::post('/edge/events', [EdgePushController::class, 'store'])->middleware('throttle:60,1');
    Route::post('/mobile/login', [MobileAuthController::class, 'login'])->middleware('throttle:10,1');

    Route::middleware('auth:sanctum')->group(function () {
        Route::get('/me', [MobileAuthController::class, 'me']);
        Route::post('/mobile/logout', [MobileAuthController::class, 'logout']);
        Route::post('/notifications/{id}/read', [ResourceController::class, 'markRead'])->whereNumber('id');

        Route::get('/{resource}', [ResourceController::class, 'index']);
        Route::get('/{resource}/{id}', [ResourceController::class, 'show'])->whereNumber('id');
        Route::post('/{resource}', [ResourceController::class, 'store']);
        Route::put('/{resource}/{id}', [ResourceController::class, 'update'])->whereNumber('id');
        Route::delete('/{resource}/{id}', [ResourceController::class, 'destroy'])->whereNumber('id');
    });
});
