# Ajouter ce code après /usr/share/perl5/PVE/APIServer/AnyEvent.pm:1484

if (my $x_forwarded_for = $request->header('X-Forwarded-For')) {
        my $proxy_count = 2;  # Ajustez en fonction de votre configuration (ex : Cloudflare + Nginx local)
        my @ip_list = reverse split /\s*,\s*/, $x_forwarded_for;

        for my $ip (@ip_list) {
            if (--$proxy_count < 0) {
                my $ip_parsed = Net::IP->new($ip);

                if ($ip_parsed) {
                    $reqstate->{peer_host} = $ip_parsed->version() == 4 ? "::ffff:$ip" : $ip;
                } else {
                    warn "IP malformée dans l'en-tête X-Forwarded-For. Vérifiez votre configuration de proxy ou \$proxy_count.\n";
                }
                last;
            }
        }

        warn "Erreur : Nombre insuffisant d'IP valides dans l'en-tête X-Forwarded-For. Vérifiez votre configuration de proxy ou \$proxy_count.\n" if $proxy_count >= 0;
    }
