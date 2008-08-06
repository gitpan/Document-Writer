package Document::Writer;
use Moose;
use MooseX::AttributeHelpers;

use Carp;
use Forest;
use Paper::Specs units => 'pt';

our $AUTHORITY = 'cpan:GPHAT';
our $VERSION = '0.01';

has 'pages' => (
    metaclass => 'Collection::Array',
    is => 'rw',
    isa => 'ArrayRef[Document::Writer::Page]',
    default => sub { [] },
    provides => {
        'clear'=> 'clear_pages',
        'count'=> 'page_count',
        'get' => 'get_page',
        'push' => 'add_page',
        'first'=> 'first_page',
        'last' => 'last_page'
    }
);

sub find_page {
    my ($self, $name) = @_;

    foreach my $p ($self->pages) {
        return $p if($p->name eq $name);
    }
    return undef;
}

sub get_paper_dimensions {
    my ($self, $name) = @_;

    my $form = Paper::Specs->find(brand => 'standard', code => uc($name));
    if(defined($form)) {
        return $form->sheet_size;
    } else {
        return (undef, undef);
    }
}

sub get_tree {
    my ($self) = @_;

    my $tree = Forest::Tree->new(node => $self);

    foreach my $p (@{ $self->pages }) {
        $tree->add_child($p->get_tree);
    }

    return $tree;
}

sub turn_page {
    my ($self, $width, $height) = @_;

    my $newpage;
    if($width && $height) {
       $newpage = Document::Writer::Page->new(
           width => $width, height => $height
       );
    } else {
        my $currpage = $self->last_page;
        if($currpage) {
            $newpage = Document::Writer::Page->new(
                width => $currpage->width, height => $currpage->height
            );
        } else {
            croak("Need a height and width for first page.");
        }
    }
    $self->add_page($newpage);
    return $newpage;
}

sub draw {
    my ($self, $driver, $name) = @_;

    foreach my $p (@{ $self->pages }) {
        # Prepare all the pages...
        $driver->prepare($p);
        # Layout each page...
        if($p->layout_manager) {
            $p->layout_manager->do_layout($p);
        }
        $driver->pack($p);
        $driver->reset;
        $driver->draw($p);
    }
}

1;
__END__
=head1 NAME

Document::Writer - Library agnostic document creation

=head1 SYNOPSIS

    use Document::Writer;
    # Use whatever you like
    use Graphics::Primitive::Driver::Cairo;

    my $doc = Document::Writer->new;
    # Create the first page
    my $p = $doc->turn_page(Document::Writer->get_paper_dimensions('letter'));
    # ... Do something
    my $p2 = $doc->turn_page;
    # ... Do some other stuff
    $self->draw($driver);
    $driver->write('/Users/gphat/foo.pdf');

=head1 DESCRIPTION

Document::Writer is a document creation library that is built on the
L<Graphics::Primitive> stack.  It aims to provide convenient abstractions for
creating documents and a library-agnostic base for the embedding of other
components that use Graphics::Primitive.

When you create a new Document::Writer, it has no pages.  You can add pages
to the document using either C<add_page($page)> or C<turn_page>.  If calling
turn_page to create your first page you'll need to provide a width and height
(which can conveniently be gotten from C<get_paper_dimensions>).  Subsequent
calls to C<turn_page> will default the newly created page to the size of the
last page in the document.


=head1 WARNING

This is an early release meant to shake support out of the underlying
libraries.  Further abstractions are forthcoming to make adding content to the
pages easier than using L<Graphics::Primitive> directly.

=head1 METHODS

=over 4

=item I<add_page ($page)>

Add an already created page object to this document.

=item I<clear_pages>

Remove all pages from this document.

=item I<draw ($driver)>

Convenience method that hides all the Graphics::Primitive magic when you
give it a driver.  After this method completes the entire document will have
been rendered into the driver.  You can retrieve the output by using
L<Driver's|Graphics::Primitive::Driver> I<data> or I<write> methods.

=item I<find_page ($name)>

Finds a page by name, if it exists.

=item I<first_page>

Return the first page.

=item I<get_paper_dimensions>

Given a paper name, such as letter or a4, returns a height and width in points
as an array.  Uses L<Paper::Specs>.

=item I<get_page ($pos)>

Returns the page at the given position

=item I<get_tree>

Returns a L<Forest::Tree> object with this document at it's root and each
page (and it's children) as children.  Provided for convenience.

=item I<page_count>

Get the number of pages in this document.

=item I<pages>

Get the pages in this document.

=item I<turn_page ([$width])>

"Turn" to a new page by creating a new one and add it to the list of pages
in this document.  If there are pages already in the document then the last
one will be used to provided height and width information.

For less sugar use I<add_page>.

=back

=head1 SEE ALSO

L<Graphics::Primitive>, L<Paper::Specs>

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