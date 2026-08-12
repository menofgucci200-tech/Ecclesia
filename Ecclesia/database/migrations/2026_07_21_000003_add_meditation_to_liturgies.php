<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('liturgies', function (Blueprint $table) {
            // Optional daily meditation / commentary on the Gospel, written by
            // a super-admin. Preserved across AELF re-syncs.
            $table->text('meditation')->nullable()->after('readings');
        });
    }

    public function down(): void
    {
        Schema::table('liturgies', function (Blueprint $table) {
            $table->dropColumn('meditation');
        });
    }
};
