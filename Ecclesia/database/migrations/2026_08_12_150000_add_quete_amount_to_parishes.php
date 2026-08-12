<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('parishes', function (Blueprint $table) {
            // Fixed quête amount (XOF). Null leaves the amount free to enter.
            $table->unsignedInteger('quete_amount')->nullable()->after('mass_offering_amount');
        });
    }

    public function down(): void
    {
        Schema::table('parishes', function (Blueprint $table) {
            $table->dropColumn('quete_amount');
        });
    }
};
