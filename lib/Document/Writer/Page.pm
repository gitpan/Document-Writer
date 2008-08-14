package Document::Writer::Page;
use Moose;

extends 'Graphics::Primitive::Container';

use Graphics::Primitive::Insets;
use Graphics::Primitive::TextBox;
use Layout::Manager::Compass;
use Layout::Manager::Flow;

# FIXME, make header/footer/body lazy and make a required color that is the
# 'default' color for the page...
use Graphics::Color::RGB;

has 'body' => (
    is => 'rw',
    isa => 'Graphics::Primitive::Component',
    # lazy => 1,
    default => sub {
        my ($self) = @_;

        Graphics::Primitive::Container->new(
            layout_manager => Layout::Manager::Flow->new
        )
    }
);
has 'color' => (
    is => 'rw',
    isa => 'Graphics::Color',
);
has 'footer' => (
    is => 'rw',
    isa => 'Graphics::Primitive::Component',
    # lazy => 1,
    default => sub {
        my ($self) = @_;

        Graphics::Primitive::TextBox->new(
            color => $self->color,
            text => 'Footer'
        )
    }
);
has 'header' => (
    is => 'rw',
    isa => 'Graphics::Primitive::Component',
    # lazy => 1,
    default => sub {
        my ($self) = @_;

        Graphics::Primitive::TextBox->new(
            color => $self->color,
            text => 'Header'
        )
    }
);
# has '+margins' => ( default => sub {
#     Graphics::Primitive::Insets->new( left => 90, right => 90, top => 72, bottom => 72);
# });
has '+layout_manager' => ( default => sub { Layout::Manager::Compass->new });
has '+page' => ( default => sub { 1 });

sub BUILD {
    my ($self) = @_;

    $self->add_component($self->header, 'n');
    $self->add_component($self->footer, 's');
    $self->add_component($self->body, 'c');
}

override('prepare', sub {
    my ($self, $driver) = @_;

    if(defined($self->header) && !$self->header->minimum_width) {
        $self->header->minimum_width($self->inside_width + $self->header->outside_width);
    }
    if(defined($self->footer) && !$self->footer->minimum_width) {
        $self->footer->minimum_width($self->inside_width + $self->footer->outside_width);
    }
    if(defined($self->body) && !$self->body->minimum_width) {
        $self->body->minimum_width($self->inside_width + $self->body->outside_width);
    }

    super;
});

1;
__END__
=head1 NAME

Document::Writer::Page - A page in a document

=head1 SYNOPSIS

    use Document::Writer;

    my $doc = Document::Writer->new(default_color => ...);
    my $p = $doc->next_page($width, $height);
    $p->add_text_to_page($driver, $font, $text);
    ...

=head1 METHODS

=over 4

=item I<body>

Set/Get this page's body container.

=item I<footer>

Set/Get this page's footer component.

=item I<header>

Set/Get this page's footer component.

=item I<BUILD>

Moose hackery, ignore me.

=back

=head1 AUTHOR

Cory Watson, C<< <gphat@cpan.org> >>

Infinity Interactive, L<http://www.iinteractive.com>

=head1 BUGS

Please report any bugs or feature requests to C<bug-geometry-primitive at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Geometry-Primitive>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 COPYRIGHT & LICENSE

Copyright 2008 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.