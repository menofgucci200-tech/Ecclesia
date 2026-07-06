<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Actions\Auth\ChangePasswordAction;
use App\Actions\Auth\CheckPhoneAction;
use App\Actions\Auth\LoginUserAction;
use App\Actions\Auth\LogoutUserAction;
use App\Actions\Auth\RegisterUserAction;
use App\Actions\Auth\ResetPasswordAction;
use App\Actions\Auth\SendPasswordResetCodeAction;
use App\DataTransferObjects\AuthResult;
use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\ChangePasswordRequest;
use App\Http\Requests\Auth\CheckPhoneRequest;
use App\Http\Requests\Auth\ForgotPasswordRequest;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterRequest;
use App\Http\Requests\Auth\ResetPasswordRequest;
use App\Http\Resources\UserResource;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AuthController extends Controller
{
    /**
     * Determine whether the given phone number already has an account.
     */
    public function checkPhone(CheckPhoneRequest $request, CheckPhoneAction $action): JsonResponse
    {
        $exists = $action->execute($request->phoneNumber());

        return response()->json([
            'phone' => $request->phoneNumber(),
            'exists' => $exists,
        ]);
    }

    /**
     * Register a new faithful and return an access token.
     */
    public function register(RegisterRequest $request, RegisterUserAction $action): JsonResponse
    {
        $result = $action->execute($request->toDto(), $this->resolveDeviceName($request));

        return $this->authResponse($result, Response::HTTP_CREATED);
    }

    /**
     * Authenticate an existing faithful and return an access token.
     */
    public function login(LoginRequest $request, LoginUserAction $action): JsonResponse
    {
        $result = $action->execute(
            $request->phoneNumber(),
            $request->password(),
            $this->resolveDeviceName($request),
        );

        return $this->authResponse($result, Response::HTTP_OK);
    }

    /**
     * Revoke the current access token.
     */
    public function logout(Request $request, LogoutUserAction $action): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();

        $action->execute($user);

        return response()->json([
            'message' => 'Vous avez été déconnecté avec succès.',
        ]);
    }

    /**
     * Return the currently authenticated faithful.
     */
    public function me(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();

        return response()->json([
            'user' => UserResource::make($user->load('parish')),
        ]);
    }

    /**
     * Send a one-time reset code to the e-mail linked to the given phone.
     */
    public function forgotPassword(ForgotPasswordRequest $request, SendPasswordResetCodeAction $action): JsonResponse
    {
        $maskedEmail = $action->execute($request->phoneNumber());

        return response()->json([
            'message' => 'Un code de réinitialisation a été envoyé à votre adresse e-mail.',
            'email_hint' => $maskedEmail,
        ]);
    }

    /**
     * Verify the reset code, set a new password and open a session.
     */
    public function resetPassword(ResetPasswordRequest $request, ResetPasswordAction $action): JsonResponse
    {
        $result = $action->execute(
            $request->phoneNumber(),
            $request->code(),
            $request->newPassword(),
            $this->resolveDeviceName($request),
        );

        return $this->authResponse($result, Response::HTTP_OK);
    }

    /**
     * Change the authenticated user's password.
     */
    public function changePassword(ChangePasswordRequest $request, ChangePasswordAction $action): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();

        $action->execute($user, $request->currentPassword(), $request->newPassword());

        return response()->json([
            'message' => 'Votre mot de passe a été mis à jour avec succès.',
        ]);
    }

    private function authResponse(AuthResult $result, int $status): JsonResponse
    {
        return response()->json([
            'user' => UserResource::make($result->user->load('parish')),
            'token' => $result->token,
            'token_type' => $result->tokenType,
        ], $status);
    }

    private function resolveDeviceName(Request $request): ?string
    {
        $deviceName = $request->input('device_name');

        if (is_string($deviceName) && trim($deviceName) !== '') {
            return $deviceName;
        }

        return $request->userAgent();
    }
}
