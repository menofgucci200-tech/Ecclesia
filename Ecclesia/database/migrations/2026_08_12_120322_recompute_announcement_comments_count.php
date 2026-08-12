<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

/**
 * `announcements.comments_count` predates the real comment thread (this
 * session's feature) and held placeholder numbers from seed data that never
 * corresponded to actual rows. Reset it to the true count — zero for every
 * announcement, since `announcement_comments` is a brand-new table — so the
 * badge shown in the app reflects real data instead of a leftover mock value.
 */
return new class extends Migration
{
    public function up(): void
    {
        DB::table('announcements')->update(['comments_count' => 0]);
    }

    public function down(): void
    {
        // Irreversible: the original placeholder values aren't worth restoring.
    }
};
