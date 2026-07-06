<?php

declare(strict_types=1);

namespace App\DataTransferObjects;

use App\Enums\Gender;

final readonly class RegisterData
{
    public function __construct(
        public string $firstName,
        public string $lastName,
        public Gender $gender,
        public string $phone,
        public string $password,
        public ?string $email = null,
    ) {}

    /**
     * @return array<string, mixed>
     */
    public function toAttributes(): array
    {
        return [
            'first_name' => $this->firstName,
            'last_name' => $this->lastName,
            'gender' => $this->gender->value,
            'phone' => $this->phone,
            'email' => $this->email,
            'password' => $this->password,
        ];
    }
}
