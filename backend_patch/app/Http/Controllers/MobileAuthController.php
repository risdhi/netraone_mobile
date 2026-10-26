<?php
namespace App\Http\Controllers;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use App\Models\User;

class MobileAuthController extends Controller {
    public function login(Request $request) {
        $data = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);
        $user = User::where('email', $data['email'])->first();
        if (!$user || !$user->active || !Hash::check($data['password'], $user->password)) {
            return response()->json(['message' => 'Email atau password salah'], 422);
        }
        $token = $user->createToken('netraone-mobile')->plainTextToken;
        return response()->json(['token' => $token, 'user' => $user]);
    }
    public function me(Request $request) {
        return response()->json($request->user());
    }
    public function logout(Request $request) {
        $request->user()->currentAccessToken()?->delete();
        return response()->json(['ok' => true]);
    }
}
