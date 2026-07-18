<?php

declare(strict_types=1);

namespace App\Http\Requests\Admin;

use App\Enums\ParishStatus;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class ParishRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() !== null && $this->user()->isSuperAdmin();
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        $parish = $this->route('parish');
        $isCreate = $parish === null;
        $parishId = $parish?->id;
        $adminUserId = $parish?->admin?->id;

        return [
            // --- Champs obligatoires ---------------------------------------
            'name' => ['required', 'string', 'max:255'],
            'code' => ['required', 'string', 'max:30', Rule::unique('parishes', 'code')->ignore($parishId)],
            'subscription_amount' => ['required', 'integer', 'min:0', 'max:100000000'],
            'login' => [
                $isCreate ? 'required' : 'nullable',
                'string', 'min:3', 'max:50',
                'regex:/^[A-Za-z0-9@._+\-]+$/',
                Rule::unique('users', 'username')->ignore($adminUserId),
            ],
            'password' => [$isCreate ? 'required' : 'nullable', 'string', 'min:6', 'max:255'],

            // --- Champs optionnels -----------------------------------------
            'logo' => ['nullable', 'image', 'mimes:jpeg,jpg,png,webp', 'max:2048'],
            'diocese' => ['nullable', 'string', 'max:255'],
            'address' => ['nullable', 'string', 'max:255'],
            'city' => ['nullable', 'string', 'max:255'],
            'commune' => ['nullable', 'string', 'max:255'],
            'region' => ['nullable', 'string', 'max:255'],
            'country' => ['nullable', 'string', 'max:255'],
            'phone' => ['nullable', 'string', 'max:30'],
            'email' => ['nullable', 'email', 'max:255'],
            'status' => ['required', Rule::in(ParishStatus::values())],
        ];
    }

    /**
     * @return array<string, string>
     */
    public function attributes(): array
    {
        return [
            'name' => 'nom', 'code' => 'code', 'diocese' => 'diocèse',
            'subscription_amount' => 'abonnement', 'login' => 'login', 'password' => 'mot de passe',
            'logo' => 'logo', 'address' => 'adresse', 'city' => 'ville', 'commune' => 'commune',
            'region' => 'région', 'country' => 'pays', 'phone' => 'téléphone',
            'email' => 'e-mail', 'status' => 'statut',
        ];
    }

    /**
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'login.regex' => 'Le login ne doit pas contenir d\'espace (lettres, chiffres et @ . _ - + autorisés).',
        ];
    }

    protected function prepareForValidation(): void
    {
        if ($this->filled('code')) {
            $this->merge(['code' => strtoupper(trim((string) $this->input('code')))]);
        }
        if ($this->filled('login')) {
            // Preserve the case the user typed; only trim surrounding spaces.
            $this->merge(['login' => trim((string) $this->input('login'))]);
        }
    }
}
