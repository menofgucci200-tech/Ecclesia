<?php

declare(strict_types=1);

namespace App\Services;

use App\Exceptions\ParishNotFoundException;
use App\Models\Parish;
use App\Models\User;
use App\Repositories\Contracts\UserRepositoryInterface;
use Illuminate\Support\Carbon;

class UserParishService
{
    public function __construct(
        private readonly ParishService $parishes,
        private readonly UserRepositoryInterface $users,
    ) {}

    /**
     * Automatically associate the faithful to a parish (no admin validation),
     * recording the membership date. Returns the linked parish.
     *
     * @throws ParishNotFoundException
     */
    public function associate(User $user, int $parishId): Parish
    {
        $parish = $this->parishes->findActiveOrFail($parishId);

        $this->users->update($user, [
            'parish_id' => $parish->id,
            'parish_joined_at' => Carbon::now(),
        ]);

        return $parish;
    }

    /**
     * The parish the faithful currently belongs to, if any.
     */
    public function current(User $user): ?Parish
    {
        $user->loadMissing('parish');

        return $user->parish;
    }
}
