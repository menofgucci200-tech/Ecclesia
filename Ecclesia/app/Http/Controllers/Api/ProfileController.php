<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\UserResource;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ProfileController extends Controller
{
    /**
     * Update the faithful's identity (name) and avatar photo.
     */
    public function update(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();

        $validated = $request->validate([
            'first_name' => ['sometimes', 'required', 'string', 'max:255'],
            'last_name' => ['sometimes', 'required', 'string', 'max:255'],
            'email' => ['sometimes', 'nullable', 'email', 'max:255', 'unique:users,email,'.$user->id],
            'avatar' => ['sometimes', 'image', 'mimes:jpeg,jpg,png,webp', 'max:4096'],
        ]);

        if ($request->hasFile('avatar')) {
            if ($user->avatar) {
                Storage::disk('public')->delete($user->avatar);
            }
            $validated['avatar'] = $request->file('avatar')->store('avatars', 'public');
        }

        $user->fill($validated)->save();

        return response()->json(['user' => UserResource::make($user->load('parish'))]);
    }

    /**
     * Update the user's app preferences (feed priority, hidden sections…).
     */
    public function updatePreferences(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();

        $validated = $request->validate([
            'preferences' => ['required', 'array'],
            'preferences.feed_priority' => ['nullable', 'in:parish,movements'],
            'preferences.hidden_sections' => ['nullable', 'array'],
            'preferences.hidden_sections.*' => ['string', 'max:40'],
        ]);

        $user->preferences = array_merge($user->preferences ?? [], $validated['preferences']);
        $user->save();

        return response()->json(['preferences' => $user->preferences]);
    }
}
