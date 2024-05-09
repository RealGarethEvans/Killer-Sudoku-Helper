#!/usr/bin/perl

use strict;
use warnings;

use PDF::API2;
use PDF::TextBlock;
use Switch;
#use File::Fetch;
use LWP::Simple;
use Carp;

use constant mm => 25.4 / 72;
use constant in => 1 / 72;
use constant pt => 1;

my $page_height = 595; # These make it A4 landscape
my $page_width = 842;
my $margin = 15;
my $content_width = $page_width / 2 - $margin; # I like to print on half the page, and fold it over to use it
my $font_size = 7 / pt;
my $image_filename = './files/image';
my $output_file = './files/killer.pdf';
my $temp_directory = './files';

#First, create the PDF document
my $pdf = PDF::API2->new( -file => "$output_file" );
my $page = $pdf->page;
$page->mediabox( $page_width, $page_height );
my %font = (
    Helvetica => {
        Bold   => $pdf->corefont( 'Helvetica-Bold',    -encoding => 'utf8' ),
        Roman  => $pdf->corefont( 'Helvetica',         -encoding => 'utf8' ),
        Italic => $pdf->corefont( 'Helvetica-Oblique', -encoding => 'utf8' ),
    },
    Times => {
        Bold   => $pdf->corefont( 'Times-Bold',   -encoding => 'latin1' ),
        Roman  => $pdf->corefont( 'Times',        -encoding => 'latin1' ),
        Italic => $pdf->corefont( 'Times-Italic', -encoding => 'latin1' ),
    },
);

# Then, put the picture into it
if(defined($ARGV[0])){
  my $url = $ARGV[0];

  my $downloaded_pic = get($url);
  if(defined($downloaded_pic)){
	  open my $image_file, '>', $image_filename;
	  print $image_file $downloaded_pic;
	  close $image_file;
	  `convert -trim $image_filename $image_filename`;
  }
  else {
    croak "download failed";
  }


  my $picture_content = $page->gfx() or croak "Can't get graphics object";
  my $image_object;
  if($url =~ m!\.jpg!){
    $image_object = $pdf->image_jpeg($image_filename) or croak "Can't open the image";
  }
  elsif($url =~ m!\.png$!){
    $image_object = $pdf->image_png($image_filename) or croak "Can't open the image";
  }
  else{
    croak "Couldn't insert the image";
  }
  my $picture_size = $page_height / 2.3;
  $picture_content->image( $image_object, $margin, $page_height / 2, $picture_size , $picture_size ) or croak "Can't attach picture to object";
}

# At some point, I might put in a better headline...
my $headline_text = $page->text;
$headline_text->font( $font{'Helvetica'}{'Bold'}, 18 / pt );
$headline_text->translate( 10 / mm, $page_height - 27 );
$headline_text->text('Killer');

# Now put in the columns of numbers
my $column_text = $page->text;
$column_text->fillcolor('black');
my $columns = 3;
for my $column(1..$columns){
  my $y_param;
  my $height;
  if($column == 3){
    $y_param = $page_height - 47;
    $height = $page_height - 47;
  }
  else{
    $y_param = $page_height / 2 - 20;
    $height = $page_height / 2;
  }
  my %column_params = (
    'column' => $column,
    'x'      => $content_width * ($column - 1) / $columns + $margin,
    'y'      => $y_param,
    'w'      => $content_width / $columns - $margin,
    'h'      => $height,
  );
  print_column(\%column_params);
}

$pdf->save;
$pdf->end();

exit 1;

#####################################################################
sub print_column{
  my $params = shift;
  #use Data::Dumper;
  #print Dumper $params;
  my $tb  = PDF::TextBlock->new({
    pdf   => $pdf,
    page  => $page,
    x     => $params->{'x'},
    y     => $params->{'y'},
    w     => $params->{'w'},
    h     => $params->{'h'},
    lead  => $font_size / pt,
    align => 'right',

    fonts => {
      b => PDF::TextBlock::Font->new({
        pdf  => $pdf,
        font => $pdf->corefont( 'Helvetica-Bold', -encoding => 'latin1' ),
        size => $font_size,
      }),
      default => PDF::TextBlock::Font->new({
        pdf  => $pdf,
        font => $pdf->corefont( 'Helvetica', -encoding => 'latin1' ),
        size => $font_size,
      }),
    },
  });
  $tb->text(get_column($params->{'column'}));
  $tb->apply();

}


sub get_column{
  my $column_number = shift;
  switch($column_number){
    case 1{
      return <<"EOF";
<b> 6</b>  123
<b> 7</b>  124
<b> 8</b>  125 134
<b> 9</b>  126 135 234
<b>10</b>  127 136 145 235
<b>11</b>  128 137 146 236 245
<b>12</b>  129 138 147 156 237 246 345
<b>13</b>  139 148 157 238 247 256 346
<b>14</b>  149 158 167 239 248 257 347 356
<b>15</b>  159 168 249 258 267 348 357 456
<b>16</b>  169 178 259 268 349 358 367 457
<b>17</b>  179 269 278 359 368 458 467
<b>18</b>  189 279 369 378 459 468 567
<b>19</b>  289 379 469 478 568
<b>20</b>  389 479 569 578
<b>21</b>  489 579 678
<b>22</b>  589 679
<b>23</b>  689
<b>24</b>  789

<b>28</b>  1234567
<b>29</b>  1234568
<b>30</b>  1234569 1234578
<b>31</b>  1234579 1234678
<b>32</b>  1234589 1234679 1235678
<b>33</b>  1234689 1235679 1245678
<b>34</b>  1234789 1235689 1245679 1345678
<b>35</b>  1235789 1245689 1345679 2345678
<b>36</b>  1236789 1245789 1345689 2345679
<b>37</b>  1246789 1345789 2345689
<b>38</b>  1256789 1346789 2345789
<b>39</b>  1356789 2346789
<b>40</b>  1456789 2356789
<b>41</b>  2456789
<b>42</b>  3456789
EOF
    }
    case 2{
      return <<'EOF';
<b>10</b>  1234
<b>11</b>  1235
<b>12</b>  1236 1245
<b>13</b>  1237 1246 1345
<b>14</b>  1238 1247 1256 1346 2345
<b>15</b>  1239 1248 1257 1347 1356 2346
<b>16</b>  1249 1258 1267 1348 1357 1456 2347 2356
<b>17</b>  1259 1268 1349 1358 1367 1457 2348 2357 2456
<b>18</b>  1269 1278 1359 1368 1458 1467 2349 2358 2367 2457 3456
<b>19</b>  1279 1369 1378 1459 1468 1567 2359 2368 2458 2467 3457
<b>20</b>  1289 1379 1469 1478 1568 2369 2378 2459 2468 2567 3458 3467
<b>21</b>  1389 1479 1569 1578 2379 2469 2478 2568 3459 3468 3567
<b>22</b>  1489 1579 1678 2389 2479 2569 2578 3469 3478 3568 4567
<b>23</b>  1589 1679 2489 2579 2678 3479 3569 3578 4568
<b>24</b>  1689 2589 2679 3489 3579 3678 4569 4578
<b>25</b>  1789 2689 3589 3679 4579 4678
<b>26</b>  2789 3689 4589 4679 5678
<b>27</b>  3789 4689 5679
<b>28</b>  4789 5689
<b>29</b>  5789
<b>30</b>  6789
EOF
    }
    case 3{
      return <<'EOF';
<b>15</b>  12345
<b>16</b>  12346
<b>17</b>  12347 12356
<b>18</b>  12348 12357 12456
<b>19</b>  12349 12358 12367 12457 13456
<b>20</b>  12359 12368 12458 12467 13457 23456
<b>21</b>  12369 12378 12459 12468 12567 13458 13467 23457
<b>22</b>  12379 12469 12478 12568 13459 13468 13567 23458 23467
<b>23</b>  12389 12479 12569 12578 13469 13478 13568 14567 23459 23468 23567
<b>24</b>  12489 12579 12678 13479 13569 13578 14568 23469 23478 23568 24567
<b>25</b>  12589 12679 13489 13579 13678 14569 14578 23479 23569 23578 24568 34567
<b>26</b>  12689 13589 13679 14579 14678 23489 23579 23678 24569 24578 34568
<b>27</b>  12789 13689 14589 14679 15678 23589 23679 24579 24678 34569 34578
<b>28</b>  13789 14689 15679 23689 24589 24679 25678 34579 34678
<b>29</b>  14789 15689 23789 24689 25679 34589 34679 35678
<b>30</b>  15789 24789 25689 34689 35679 45678
<b>31</b>  16789 25789 34789 35689 45679
<b>32</b>  26789 35789 45689
<b>33</b>  36789 45789
<b>34</b>  46789
<b>35</b>  56789

<b>21</b>  123456
<b>22</b>  123457
<b>23</b>  123458 123467
<b>24</b>  123459 123468 123567
<b>25</b>  123469 123478 123568 124567
<b>26</b>  123479 123569 123578 124568 134567
<b>27</b>  123489 123579 123678 124569 124578 134568 234567
<b>28</b>  123589 123679 124579 124678 134569 134578 234568
<b>29</b>  123689 124589 124679 125678 134579 134678 234569 234578
<b>30</b>  123789 124689 125679 134589 134679 135678 234579 234678
<b>31</b>  124789 125689 134689 135679 145678 234589 234679 235678
<b>32</b>  125789 134789 135689 145679 234689 235679 245678
<b>33</b>  126789 135789 145689 234789 235689 245679 345678
<b>34</b>  136789 145789 235789 245689 345679
<b>35</b>  146789 236789 245789 345689
<b>36</b>  156789 246789 345789
<b>37</b>  256789 346789
<b>38</b>  356789
<b>39</b>  456789
EOF
    }
    else{
      return "nothing";
    }
  }
}
