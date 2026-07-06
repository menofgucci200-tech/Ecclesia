<?php

declare(strict_types=1);

namespace App\Http\Requests\Auth;

use App\DataTransferObjects\RegisterData;
use App\Enums\Gender;
use App\Http\Requests\Concerns\NormalizesPhone;
use App\Rules\IvorianPhoneNumber;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class RegisterRequest extends FormRequest
{
    use NormalizesPhone;

    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        $this->normalizePhoneInput();

        if (is_string($this->input('email'))) {
            $this->merge(['email' => trim($this->input('email')) ?: null]);
        }
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'first_name' => ['required', 'string', 'min:2', 'max:100'],
            'last_name' => ['required', 'string', 'min:2', 'max:100'],
            'gender' => ['required', Rule::enum(Gender::class)],
            'phone' => ['required', 'string', app(IvorianPhoneNumber::class), Rule::unique('users', 'phone')],
            'email' => ['nullable', 'email:rfc', 'max:255', Rule::unique('users', 'email')],
            // A simple, free-form password: the only rule is that both entries match.
            'password' => ['required', 'confirmed', 'string', 'min:4', 'max:255'],
        ];
    }

    public function toDto(): RegisterData
    {
        return new RegisterData(
            firstName: (string) $this->string('first_name'),
            lastName: (string) $this->string('last_name'),
            gender: Gender::from((string) $this->string('gender')),
            phone: (string) $this->string('phone'),
            password: (string) $this->string('password'),
            email: $this->filled('email') ? (string) $this->string('email') : null,
        );
    }

    /**
     * @return array<string, string>
     */
    public function attributes(): array
    {
        return [
            'first_name' => 'prénom',
            'last_name' => 'nom',
            'gender' => 'genre',
            'phone' => 'numéro de téléphone',
            'email' => 'adresse e-mail',
            'password' => 'mot de passe',
        ];
    }

    /**
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'phone.unique' => 'Ce numéro de téléphone est déjà associé à un compte.',
            'email.unique' => 'Cette adresse e-mail est déjà associée à un compte.',
        ];
    }
}
