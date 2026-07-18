<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Annual subscription fee (in F CFA) each faithful pays for this parish.
        Schema::table('parishes', function (Blueprint $table) {
            $table->unsignedInteger('subscription_amount')->default(2000)->after('status');
        });

        Schema::table('users', function (Blueprint $table) {
            // A parish administrator signs in with a username (login) instead of an e-mail.
            $table->string('username', 50)->nullable()->unique()->after('email');
            // Parish admins created from the dashboard have no phone; keep it optional.
            $table->string('phone', 20)->nullable()->change();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('parishes', function (Blueprint $table) {
            $table->dropColumn('subscription_amount');
        });

        Schema::table('users', function (Blueprint $table) {
            $table->dropUnique(['username']);
            $table->dropColumn('username');
        });
    }
};
