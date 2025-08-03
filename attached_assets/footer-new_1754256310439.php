<?php // Ten plik to /includes/footer-new.php 

$is_supok = isset($_SESSION['role']) && $_SESSION['role'] === 'superadmin';;
?>
<footer class="border-t border-slate-700/50 mt-20">
    <div class="container mx-auto px-6 py-6 text-center text-slate-400 text-sm">
        © <?= date('Y') ?> <?= htmlspecialchars($appSettings['name']) ?> | Jakub Jaworowicz <a href="https://jaworowi.cz" target="_blank" class="text-blue-400 hover:text-blue-300">Marketing & WebDevelop</a> <?php if ($is_supok): ?>| <a href="/admin/admin-logs.php">LOG</a><?php endif; ?>
    </div>
</footer>


<?php
// ZMIANA: Dodajemy bezpieczne wywołanie dla niestandardowych skryptów
if (isset($custom_scripts) && !empty($custom_scripts)):
    echo $custom_scripts;
endif;
?>

</body>
</html>