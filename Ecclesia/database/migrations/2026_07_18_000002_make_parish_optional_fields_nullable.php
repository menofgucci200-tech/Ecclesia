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
        // The diocese is now optional when a super admin creates a parish.
        Schema::table('parishes', function (Blueprint $table) {
            $table->string('diocese')->nullable()->change();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('parishes', function (Blueprint $table) {
            $table->string('diocese')->nullable(false)->change();
        });
    }
};
