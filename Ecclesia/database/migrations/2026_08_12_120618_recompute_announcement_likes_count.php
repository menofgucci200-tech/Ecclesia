<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

/**
 * Same rationale as the comments_count reset: `announcements.likes_count`
 * held seed placeholder numbers with no real "like" ever recorded — the
 * like button was decorative until this migration's feature. Reset to the
 * true count (zero, since `announcement_likes` is brand new).
 */
return new class extends Migration
{
    public function up(): void
    {
        DB::table('announcements')->update(['likes_count' => 0]);
    }

    public function down(): void
    {
        // Irreversible: the original placeholder values aren't worth restoring.
    }
};
