ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:0.13.2
docker tag hyperledger/composer-playground:0.13.2 hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� ���Y �=�r�r�=��fRNR�TN�Oر���&9CIQ>���U�DJ�I�l-8�#�\HQ*��'���@~#���|G~ �0ëx�,��]�it7�nt�h�Xi"ӧ�V[���a�nb�P�����a�@J$"���hP�OKH"OĐ	�A1=�HH�� ��/,�eC�'�	;�5n��_i� �Ұ�^_p��̎� k�� �d��!��7Æ���s����){��`��5zmd�H�#30x>&R��M�rQ�/��ma��y����Ll��a�����R�x�8̧���� ���'Zx����w����-dCڐ�̆`Pސ ��|(��-OF���G����~Ad�X�i�JH1�M�˕R*��i�X��0�۰� hHwa�~���?7Od�@�M���5MG�������`�ԔE�W���Z�v'��IH�Ơ#��El�ģ�6Q��%�>��-4�(�d�T2�ԭ�t���� ,�æ�L"rK�x��q9�NY��me'�0��%l�uD{����i��?_(�BqŊRԠjA����&i�C�.�JG�`��j�`��7l�M��@?&x��/-S��|�h?���C�F4�&�� ˮƦ�bf�t��q���b}���mAS�`8�~�?���dw��dvEE5���@�62�lɤ�:�`��m�?_qW`��:>j����u���<������DH�(����dF�����o#�F���W�ո/6����O���8$��D�?*#k���w��f��jpvL��&PT�O�L�b���q��w^:��w>�x�����Uɧ���!q6��|�k鯱����t:?������������.3���&�#�����������bPO�dm�WT�s��)l9v"�~�vk��f��F&(�:�Б���#P�&٫u����P����ڎIwfݶ�u�MY�M�*�皍���4`x�S�lo�;~`�-y�p�t�yFic�[~ڞ�6�<t�6�Ϝ^�?]S�a1�2њ���(z�Dv��h�ϏpYձ�Tpxj�[Xw�Z���0��AvÊ������o�ơ�h�ꃦ��:��;z�|�=�~W�������d"�7� ����?��'�Z_�Js�~ix�>"�=�M=�!-�� ����&���?Yד���}]�%�_�<�\����~���2��q� ��@�1�a>��MM�4T`�� R����f�G/�,n�Ȳq{s���#q����D�-����i5��z�G"� ��<>��(� ���O�Qܐ��I����� @6��z�3W���$q8N=8�z�vr@�6d�`��F���(����G��%� �@�sAؘ������医�1�Q��v��=��vu~�� ��4�.��̲�TF�q�������$z����z������O(���`Ǌ�A�=t!���h6kDyW1�سd�\���t-,�#�݆�4 f�������d�	�l��:Yo�yJ���<D=h�6������5a�}�JI>g0ã�i[L�^P5l�~=��<t�����5�.5۫GT8hm���2��SAz��Z�~�	G���_EY��|�e�����h,�Q
F��_\�����~Rrt�zg��;�!��>��Qw��:�Qo7cª�9�I1�U�x?��q�lq�����-����Qy�g�6!�����yvEog����p�e�9˾+���x1�8?NK�������m���	 �Y�1,d�"N��(7l��_��50�`׋*�n��8	F�x�|�a��Tn�[*���y9�KV�� �Ż�"��Z[7�0�zW�}�~��v_����}x��E���ށ�3	��<7���$̹����W�iU�Ƀ��fn)i[:&K::=� ް!#�������i�  ���_����+d�`��N΋軏5����k�o5e��}�e����Cn ��H���h(���U����٧z}όvh�]>_�D5��8A<dг��U��e��O�K���L����������?WP��?���K
�<���z�WRn;��	
^v�#DCS�
E��%e��o��±A��ed��|ڦf���V����܇:��#���ba'��c"N.&�vv����~^|J���c"���pl�����`�'VϲQ� #�=#�9Ë��������tp+�jS5�r��0s+`�"�w읦��� )q���5���{f�[u�b�pO]�)�э��c�Xt��U&^+����S��j�w&p����fw��#h�]��B������e�?*M���B��[���_����HW���G�"bú��B>:#*��=p�5?7����@=���w���~�/.�W���dt�����{'�Qju��������'(`����Ȕ�á��������8�,����6���{��O�	o�f8~Tq~���m��>/����F��_����+)���Gy���e7D�;����C
n� 6� ��'`�9 �ìc@�V��|�yX9�=c� ���F��I ��Q׀׵9��n���� u�?�r�FO�E/n�.�x���)J��K6`�5��gز�$#^2/i���c:E�D�&�,���%���ac*5���ԧ�e�J�1�`,�dW��<��;̥�3�,ϟ2/W�X�>$<��xQ2��.d4�EL!2<�T�g%�nl�W3�������|����p�@����b4(���WQ�<��E�]����2t�������pXZ���p��5w�}���o��������_��0e~�	���"I��vMQ��Z�&)۱X�V��`"IDRD�Uc!I�R,����v8X��7��k�/_sӈ7���Nn�u��/���6�������'�>�6,lښ�����6lT��}��&���W�|5�����Y�;k�_6����mp���H��~"0sb�ͫim�a�)��a�8L�h�1�b ���v��w����y�w�q��?$���ՔO��a����X��oοB�����c�'�[M%uÝ� )�I���5�Р���'Oo�6���w�yK��s�,���="��UE#՚�D�C�vm;�j�T�VbR0��LD�U((!IP������0%)%$�!�k^AdY�Q+@��%��d� �*���lB.�X�{#��&2���$�r7��٢�w���˞�gz�mTé�^�&��}|���R��\�����J*��%��s��+���	�r��oT3z�z����e�B��ϔr�<�����J;�A��4�}�)�o]\Neb����s��Ѩ��[g��E5(\�%e���ʩ`���8ḧ́��5�|��t��`�����	��`u �qr��
V7Q8M
�T��q�*UΑ���K�s��`ڂ'g�n��S'�x���e.�ި�N6u�;=	_�����U���B�vO
'E��e2F��Q&m+�K����T��32��\&���)夘\Oe	�s7�'Y9�q��/�1Ӽ,�s���Ϳ�N�O.�v$I��X~�3�'�Q�X���}y?Ւ��sѳ�Y���Η�Y+�#gR���w�/���AN��\n�d7tt���I9G�z���˵�|!˹�E{�f��f.�/g�-�:�x6{o�Ńfw����"������HGrZ�Mx�H����gd�P�s�J"[HH�~!��H����S$mëX�$hg/��l���J�8�I��z�^
�Gp+����4N�a*��ŢN���8�w���bю������T>9C�~���?`�~��GZc��f����r��"O��#�3Q뿉��n��_i�D�ߵ�GS�|ˊ���?4��'$��u��Jʘ�tT�� �S���)��f��M���xF�B�C
uA�v��XĴf5�;;������3'����I�\�F�i�+!�E���
�|���4��0}yu,�:~YE���tܬ�
�p/��Q�r��h�D�Ĩ`��(9��8���^Y@-�5p.�Z���ܣ��)��/ݴ���_E�l�ߩ~˓_��β����+)���?�&����MuO��㏄\�$傒,���v�T:Y������I�	X"zSoãV�)��g�\3��x��9Nc�e|����W�a���+XZ�R����z9�r}ww܀Os��G��S>A�{m����V���-~%l��Gn���u��Քg ��=��Ef�9��l����H�,PDL.T?��FY%��ܴ�>�,��!s���8�{�B��nҡY�x�IT��EL��ꂆv��-Ђ���'^�0��.�<$Kc�П�yX��G�p�@��Έ I܂����X�CӦ�R)lK�ځ�"�"wY]jtd#0�`���a��~�n[��A��<� �{k)��m�"�NK~��
/C?�������G�_1h�-���,��0�,2`Uw��K���Ǯ�D�F&�pV�Î��s�c2���#0��x���c,��eD��蕫�.�6�  M�(AZI��MYw�؀Q]�Ҷ4���S����=��8 6�裣���(7���/�S���ay�^����$ȘaÕ��C�d@}��B�����G�G���TD��!��B�&������^���M"ޙ������:����7W��}~!/7m�^k ���v���L�b��>Q�KRs0�h�&��T�:H��M��V��ٯaL괖;)z�fN̯ە�'��(��C���ZCR>zL�B2ϲ��*���R�s�oqh��/ĵ��ѽ��D����&�vi���a��Q��e��!d��:࿩%:�M�Wk"7P��T�m%Ѕ'�����;�1~��^R.�Lq�Cf	�&k��ʽ�M���׆�.�f�~���y���Cg�P�K�m:��⧪�9��-��
�1����Ȯ��!�T�����(�c-"kŠl��b����t7�5��u�)n�wl]����l���eH�P�t��c^�����Ir�kp�m����j7�V�T��nG,�O�O>f�4��b�󋏦N��,���'$��V �>��9��PU���S�c16�����-�Dz�o�B[~�#&i,���RH����?{��8���{���nz���B5Ӎ�R�Gb'�LIm�N��8O���ʉ�ĉ�'Y�b��f�%���nF�CblaX ��ĂB�5�?�<�*�P��ֽ�y��u����A�{I��G�P�K��������_|{�W�����s��������_��7��K��q�s��,��8z����:�1�
�n]C���ga*Ɋ�I��"����p�)��B����12܊�BFe� ȶ�r���$��G�������7��'���G�����}A�������!������}���V����﾿`�������{���!�5����������i���� 톋! -V h1e��
l���F��cCK�R
���&�ҧL�s���r�B��{�����«\p�CW5�e�
�ݨ*�%0#�5�:�M��i%ab��&�^}.�
��kHֳ����=C��0�/鴍@���V��`r��x����|��́��u3A�w)��Ek�Nq��6�q��΄b�L�0�)7g���A%\��f3Y�։�!M3فyX��g{��;�5��~���:�F�}��_���@Μw��s�0���X?ŗF�˗ٱ�k�A'r�B��:�7��2���J��9S��2ee$�R�-$0��,by��B�Z�Nr �Q�K[�#��$�$��ɚ0�hg.�4��-�1����)t����Gt��"n*���� i�I�;
S�_-2�a����71�lѪ�H��b�C�r�`��d�j��X͔��qg��r��/O3�N�OִV���Y�T6�tr�g�&%��Frʏ�C
m!Z�K��l~�]���t�%rW�%rW�%rW�%rW�%rW�%rW�%rW�%rW�%rW�%rW�%�py	c0�"o�R4x�$��?\�(%��cO�p���cLo�S�lӊ��b[���vV8�rr�D��A�C!U���A�ꉚ)��n����۩��?�n{���C������9Cd�x6d��FU,�zm��G�j���M��	����sS�<N��p�hjr,_���hl��6Y��V?��n�~"��>�ӱ0&!�2��-k9B�©�D��&ފ�<e���s�B���S�p,�#S.�|&;��ә2k&��j'�.Ȑ���d?�ӵL���Z6�'.�;��T�Q�MZyD�ڬ�����,J�K�̻��z�������oY��q�ڣ���-���
`�^�/���^	��g�{q�\l��a~���E���;G_�}���C��5�S�E/��7�@���˛�7�y��X��> ����� ��@|�?�ƣ:��<|�a�z���?�R�e��(������,'�*�g��,)�(��������u~��K�Ώ�|�2�`a9�,%r�Y���+���X�~Ʌآ�`rGt�Ʀ�	Lٕ�9 |�
L��H�L��(�Y)�aL��,�T��*0K<��L�8�>f�y%�+ 1*��N�� ��߬����o���E�M�����1o�i=ڮ.k�D����te�GM�&�9[�D���jY��I���d:u�N�t�o0"�i
�d�SP�8#5��@eh����v�8^9�D)9:�$�|���Q�J����>E�e'��Y��UZ�)�~��l�b�<TpLTj�p���,�F6т>��b!���Ƙ^`�8�e�J7�)Ǎ�0S�{�0����N|�ۿ�x�[W2M�M�P.��(ϗa��p�LN�L�����p�_����M9��+����]W?"W1�+r!��/�=n�e���6����3�{fVz\�ew���;m�]w�g��~��M��pĿ�\�C˞l�j5�7fI�g�D=���l���Ò�͠���Z(���2�g�S�(F�,1��\��<=���^mdi�T?�fNߡ�Z�M�P�lC9.дyj3K��L~Dw���@�:�|��$R�YGkO�#������Z�`��|�O��-U]�*,�.-H��V-�W����NU�bYs�Rd�F�P�7�yC�R�bQ��Ê�h2�l��)��"t�5\�W�u�~�1B��Q4�,<��M��W�DV�d�R$Bv6(��552����RHزJ�&�_E22���H�	�~Ԑ��I*�G0�2AVv��D��c�2)s�U(��{�B)���B��:���uJ+�9$O�j��pI�?��:ݮ�Y�P�;�<Ǹ�ѱR=�������V.�*�dH[F�3�.��Qn�PW��P(�r�.������piJ
^ԇf�����y�S�y�� }),����)��f�R��;�4YhΧ8)W�tC�k��<O�HX#H���&��Q�1K�:6�MS`��QXbe��Bl4Z�X)�j9�2f�����.����,��.}7���t�
��x�2���|�B��K�C�-*�1Q��b�#7�_F~��*C}����xxySi#/�c�g�huK�R	�x�y���s���σ^�o!��<��()�n�M�b���S����Q�4U�}H���5�I\����)I!ki�3�*��i�8"�����8Xɐ�%��s:�Sw��V����G8�C��D�uE��Gȇ���)z��p/r/�r��f�wHwI����D��z�_�����Q�-��~�����r�@}�l?t\�:=	�j��@��kH7�˝AM%�@/�r�ke��G���aU�Ki��]�ȍ;��� �H;�q9#�O`�E�O�#c��gv��~��������?uް6�B_ː�K���<~�:����>����غ]�-z�:@N�J[Ŝ���Ɏv�l>P;������cu�euɆ���ãqя�E�#~?zX҂�c�|�� Sk��~��B-� �g�+bw��/��7���B;�z�M-�18��b�`��I0�A�;�jrp�X:
 ���T���Ԟ���pe Y|�B�Al��ja�C�٤�$����(�Џ�����p�Dd-:����>�����Z�i�zW�x��L����w��~t�W��"5�Z�,� ~Ҋ�y֫������U'.��&;��X2����ں���x��U��.�#��+b@}�&:���Y,@'�L-�q�Or+! l��D�Ա���#�F���������	�˭~f@�����9���O=����3[��\;ؐ��_����bS��_��,���UM��d����s��EC��ӡ#�-��6���҂��u�&����-o�C�b�$4`en��f#�O�(�-`��ɏ ��$~y���|.��t��qp��"(�fK�-�x�Kv��V�>aP�:W�&���+���h�R����E�<����v ����{���]�LR5�2�U�?��!��q_j�%v�4a� ��m{[�'<	^��v�O1��1��_i P�P�X�A?MI�#�T�l����Y�I���k)�΂�������2k��I .�rXǚF��A�.�����:�v5`U;V&k( ?��=n�ܩ�!c���5�SK��f��aM�=W���v� �p?2m��_Y�LTI��%�����ӕ�s��Zv�E���]Z_�b�F��ދ޿ �>��	p�mX���n�����!�"T�i|��U��m��j>���&�ĉ�3#��ON|-3�Q��Ú�C��y�M�$p��:��u_Eٜȝ <t�ϟ���Ñ�n��mm�i��<�@���#V��9�1��.���E�[@�BSv6��
t"��{��}���f*�9����n)�pḡ|zl?�@�)����1����Zl�X����:�����v��+۸��?!6���v8��G+��$��l�dG�[V�`j'��2�6<�{�	�)��8}"c<C���Ρ�K\���oYڪbGg��.+>�%��5_�Z���>+W4t��o֎D���T���&��D��٦�v���q9��%�h���c��l7�1J
���DPҙ޷P{���A�;�
|����n�I+��fl�7��z����(v,�7av�}eq�*�ԤH��lb�(�%'�p�b�$QT8�D�(UBRS!$��5�ј�(�DI�51�'M;��	�96�O�O�l�,�m����)z�sKBO�;g	��dg�=�]Tleܵ/�Y~G�+8vW���6Wd��E�I.���Y&��p.�LV��������ei�-r��3ZW؅���%�$pb*�>�G�Wd��^����.T���<�>��]�D����@�g]�\T���#;���:hg��P}�B;�ѝ6!-m��:Ӻ*v0:�2����m��6��ӵ���vn�(t�	�nus���w���KS.&��(��{<W� �'�l�,�q�B���)���s�*��,ǔ��Y+��e�9>+>���	����5:�&�d:tl����>aI���E������v�l£�;����U4�+��\6�'ϲ�X�Okt�\6:�_�]ot�u���L�S��<-��yt�c��"pl�*[i����H3t�{!OY���\9�bgL�_��S�X4�B�����Q��3{��䳶���,��/�7��]�����������͢��m7�o��-ۅ~Lv��
�.+ce(�g��;�ڼwI a�R�nm��\��
ɻc����p�8b��r1c5�8B
8*:�����n�߮l�n�%Lb�C��}�;��6��h�����w���H/|��d�m�?DD����#���I|��7v�����������t�������������B����*��6�?	��>Ҿ�?�y�'�����lڗ����/Nn~�����}/����������z��o��Qz%�?rG�������/�O�c��l+XkG�2nɎ0���v�l)�ԊE�xK��X�j��H�	G�&&+x��Zg�ˢίvz��!
߶����|��f����4��5uh�ÑVF��s�"��є�0p��Ns�|]W��ʌ���J�s�]�� ��R�9,�"ch$[\�O�Ѳ���m��!iY�����I)]�M:�⤫��Sf5IƻcTc/����K;���*��������/�ml�}��v�}��m��q�p����*��q�:��}�}�����=��|:�������u�GF"���t�� ��{
��� �����?�>�9��{I����Wq�pJ��t����򟤶�?u���H����~?;�D���%�/��	jK�����}�C��C���c�ʺE��=��w��y�x���TDP�y��(*ʯ�4�U���R�+g_��TR�n�����Q���ΟB-��`��?JA���B�_�������O�� ����?�V�:��v���C�o)x��7������)u���e��~��:!�-�\���,*���5!��Z��O�gv?��!ZG����u����g���Of��������'�4p��
�\f�P�ga���f����ϭ�4�T���sŖ�U�
�|��5��Nc�!��ҏ&�͏a{hӗo����{���O�G�>��~�e29��{�`�[w�F�.���>�$9����l�nɿ��ϻEse/��ԕ#m��8vE��gӻF��b�ҴP{�HTړ�oS�{��~ȷ7,L=���˝���%#�LcG����L�Z�?��W�迧Q� ���_[�Ղ���_����U6jQ�?�����R �O���O��Tm��@����@�_G0�_�����������+�S��e�V�������Dԡ���������u������u­c>��3WUch;�~��+��������ϝ�謉_�#o�����2y��'�[���P\i�����Z1ܥZ����.�8)�����=EP�Nb7�Θ������R�7ۛ!�뚜=���_����������wD��s���_��+	��6>r�㿷�o^~��P�J�x����X��.i|JI��Ηڔ�	:!�Ͷ��Q����u"��p暤 ���n�Prd�
'��KF�h�O������������+5����]����k�:�?������RP'�f��3
|����<��P��I���g}��	�f|��|��i�"8�CC��qԁ���C�_~e�V�uq��d�l5uɒ�=�
y�A�΢�M���_����͑Ώ�<?�(��U�,�LL��t�sv��i`�M2_o��v�e�K����s�^ڌ���?l�'�:���^�����ա���~]�JQ��?�ա��?�����{����U�_u����ï���![Un7㈉L��g4�r����d�p��O�a�n���#�<�A3f\���].ջm�(�sd���/�'�D�:�2B?&�=2�U.tf��e��9�g�`l�<��M�s(��ދz��q�+B�������_��0��_���`���`�����?��@-����?�W��Nq��=����Ȼ�a=az'	�c�4������|p��om�rQ[�9 yz�'� @��g�p��~{���C��\x� �8�rh�|���'�Z$|�.��4ZMA��J��Y��4l���7"}8�1ꄗ�C�]דv�)看z3vN�o֋��s$r��n�<�k�����g vK�5�R�Hn	���w��]�ӌ�A���#A�X��ﺡP��HaY}�'�~����ib���`sMh����r&J��R�""L�������dCT䑊��C�j���[�Bc:U;BOg��� 	=�nGd�-�=>!�ͤo�E��W�u�u��~���<:	:���VW���z/�A�a��G��+���]��/ʸ�o�������`��ԁ�q�A���KA)��~�EY�����O�P�> ���!������`��"���0��h��<%Y�	� �C�G]�u]�&��AY�	���A��,�L����b秡����_�?��W��:}�,�Ԧ��c�{�hċ'I�ɹ���kdbP����9��IɃ�i�BK6J�A�{l�Cd�&�~��ݤ���������6�yFͶq�7މ鴬]%�-��}/�p�������S
>���U?K�ߡ�����&0���@-�����a��$���n��!㽎 �����/W��*B���_��?h�e����4�e����k������f�7�ASh��	'�re���E%�����e\�#?3�}}����k+����<���S��N�� o�~��z��<��6JzGF��Su����4G�C�+t6��xĬ��lꪼ�r3�)�q'�%V7%ӂ��vH�܎ruaYBO��6r��J�Y��kۉ�w�s��A8d7�-su�M�f�+n��C���x�ꐮ{��ʎxM�E��L5hD���gMC�u�s���i0�B��fl�#�(�H�LJ����=I+�SWVr�c&2i����g��c��C��c٥������ߊP������
�����������\��A�����o����R ��0���0��������,�Z��������������ӗ�������$��e �!��!�������o�_����!��Ъ�'�1ʸ���I��KA�G���� �/e����-T��������
�?�CT�����{����Ԁ�!�B ��W��ԃ�_`��ԋ�!�l���?��@B�C)��������O����a��$�@��fH����k�Z�?u7��_j���R�P�?� !��@��?@��?@��_E��!*��_[�Ղ���_���Q6jQ�?� !��@��?@��?T[�?���X
j���8���� ����������_��/���/u��a��:��?���������)�B�a����@�-�s�Ov!�� ��������ī���P���v�2�7C}�%Pv�r��'=��H�/$A������.�2.�a��r.IR����z����4�E�S�?*�K�U����v�Rq��T�
m4w�ހaD(�佞�&q����8}~���$�����jI�_Uc��C^y~�;��a��T��E��F1"��*ixa����}6�ԙj�B�u�v����N����C����d�=�c��:�y���K��'U�^3�����ա���~]�JQ��?�ա��?�����{����U�_u����ï��>�Q�ƾo��FM�}�7��b���_���i�Sy��V�ܛs�M�߰��n��� ��E�C�*Qx�N-e۴�����|����v�դA���f������f1�˔��{Q������������}��;����a�����������?����@V�Z�ˇ���������?�����?���q,��91�ő"����_+����Y�]��$8���Ro�X"���#Ҟ�[���lH�%��I�3M��`$H�v+�,���z�ڽhL�Ì��0R�/�=������^D�dA���gZ;ɑ{m7�^^�k��ӥ�����rM��vB$�����_���@w�N3���>��c�b��B���E�I�0��N�jv�,��l�J�9y�����Ǽ��#b6P�n�8B֧�ə���h����ǂ2���zn�`A�\���I�v&T#<l�es�I)fk�����I�OvA�{}x�;~���28�K�g\��|���'.��_�P�a��O��.���Jt��ڢ�����O��_���8���I��2P�?�zB�G�P��c����#Q�������(���{����F����A�8��]B�������?Zo��?D�u�4��ώ�t�Q�^�
��Z;������q������K�7߿�.]M�n���j]^��kj	��ؒ��[B�8����u�!�ԙ�a�#_�FF�́�(u5^��Nn��T3~6�٣c�J��E�J1w�s�ToR¾���ʶ�ѼM�
�p������'�nѲOVޓ��No�����B4��_�?��~��7[���NS���� 
�ݛZ[�!�M��!6�6�u�͎A5!~��tI�c�r�#��K���>��&+`٥�t��`4���L�Ӏ?�r�S!���H���n�Bn����]{�&Ч�Q��ܔ���r̙}i՗_��Z�?�n���%���x���ž�H��f�����I��f(��8=��Ip3�`<ڧ|4�8�Q`���P���~����`�������f|���A�<��`7y���8�ݓG(e�sG_����ʟ�
��rU+0��^|���j�~��Ca$�e��c�{��_)(���_�Q��������h���-��W\�?������c��ba �Ϻ�'t0���?�*������@��SO���`C>��-���!?��]�?���D��׿�~7�y��g���B��:́�nCJaka = �G5�֘�_��7�4�5:pbu�Ӽ��B?K����|����d��F��vGW����w��������:�f����G�ٻ�d�+��,M[f2��tY�*�����Ix^&m���z=�P+�0�rҿ�(JyM#[/��G��Oռ�*E3C�a͹�	��*l8�Mo�,�d�W���ܝf���}����G�?��[
J��S.�~H�,�3ǯ?��|E1a8�<��\�e����]���8F]�X� ��Q���q��x�����|�J��ա�i��vN9q�4\��9�v���}�7N��w����e�U� �-��������~��c��2P�wQ{���W������_8᱖ �����!��:����1��������w�?�C�_
����������ƴ�T{mh�^Of{�,:̇���/��5A��?�^���*����Gi��o!
ȷ�@N$K&4iz��Y��g}�\S���=��r�ֹB>ں�u����+��忧���޹?��m{�w�
nN�Թ���!=ur� ����֭@@| �:5����;�DgҙI���>UI�"l���{�����>^���Jxa/�<���i9�Bg\�D{[[w:�T��hV�n�l=����}s|��*&��h�6�2�rڶ�t��H�1k	\�m����J	/Sh
�y���y�G�)q�<��n�x�=���gw;�b�ꇽ��v~��6lIi6F�í2�%Ym^���'�u����vcR��ld���j0��U���UL,ZJ�Ѷ�f�~���#ؕS�벵��R��p�qT��J%)�H]�+����|ß&�um�o��Ʉ,�C�?�����_��BG�����#��e�'_���L��O����O������ު���!�\��m�y���GG����rF.����o����&@�7���ߠ����-����_���-������gH���!��_�������_��C��@�A������_��T�����v ������E����(��B�����3W��@�� '�u!���_����� �����]ra��W�!�#P�����o��˅�/�?@�GF�A�!#���/�?$��2�?@��� �`�쿬�?����o��˅���?2r��P���/�?$���� ������h�������L@i�����������\�?s���eB>���Q�����������K.�?���D���V�1������߶���/R�?�������)�$�?g5���<7׭2m2��ͭb�5M�dR�����d˘d��ɱ÷�uz��E������lx��wz�(q��Fu����u��
M�)�ǭ�o2��wY��^�պ(����t�6ǝ6&w�Ɋ~HS,��8�m��/k��Ȏ�d�)-zB:]=h�V�E�Gu:,�q;,����m����d�U��\OS���՛�nǮU#�rEy�'����$YG���Wd�W�����E�n𜑇���U��a�7���y���AJ�?�}��n��%��:~��'jv��w�^���b�Q�ˆ��m��m��E��Ξ����Fu�j�[��j���#��͆�6,E�D8��~],���ߪb۰�sUk��ɫ�v��]mN���&�P;z��%�����7�{#��/D.� ����_���_0���������.��������_����n�QP�C��zVa��U���?��W��p���)VĚ8�)__�_ف����6��h�@*���z�.K�l�?���E��5}4o����D�0.L�x\��!iͱS��ˉI�U'�N��z�����~Q�j�J)l�[m,���m
��:;���_e�*��і����D�Z�F�1M!��bwXO����h�IJ�}v~s��V�~������^�|Jb���*P���r��KQ]٨5�V���v9X��ͦ2⇃8?LKQUZ�X�8���N�Y2D{�����qqېI�]?hB����|/Ƀ�G�P�	o��?� �9%���[�����Y������Y���?�xY������������Y������&��n�����SW�`�'����E�Q��-���\��+���	y���=Y����L�?��x{��#�����K.�?���/������ ���m���X���X�	������_
�?2���4�C����D�}{:bG[U�7��q������0�Z�)�#fs?��
����s?���L�G����"�w��Ϲ�������uy�ݢ��]�D�����8�P�;fm���\����j�7��O�gCvfNcap���M#��8:�!,Y��dSSmG��Q����Ѽ��_�Jޯ�WOG���\�F��4��
�}8V�����tu���_����Ug"��`1�lF90'<���%ik��Nt��jX#9jSo�}2�V,�X���`�fa�w��ReCi��DpT���vra���?2��/G�����m��B�a�y��Ǘ0
�)�������`�?������_P������"���G�7	���m��B�Y�9��+{� �[������-��RI��_�T�c�Q_D��q��Hmك�d�S����>�ǲ�<<�����،��i
���=��)������0��ыFI�h���z~��T�i��,u��7CS��W�*G}���hA�F�P/rq{+��eY!F�o� `i�����$�����B�{�X�/t)E�W��|aʜ�b�-?
�¢��nkO�����lX޴��P�G&��^S:K�X�!m�WЭ	�m�������?L.�?���/P�+���G��	���m��A��ԕ��E��,ȏ�3e�7�"oY�fh�f΋�N[,�s�N��E�d�l��a�OZk�:ϙ�O�9�c�V���L�������?r��?�������O�H&O��Q�Q�Nf��j�j�4*���<�ބ&{�`��Vb�埈`g��kL^�J���������ʝJ]X��5rr�4׉Y<�ZV p�|��n4��?_K���������q�������\�?�� ��?-������&Ƀ����������z�X�􎬊Ĝ�*Ċ��K���[Q�Ew��/�N��>�\_:���`K��_a;�YRL=4�,�G�~u�N�����[�iW||Ռڲn0.O������&^����24��%��E��3��g����``��"���_���_���?`���y��X��"�e��S�ϖ>�����ct�\���t/B�����S�����X �������wں�E[M�$������q��tc����r�J̧2�"��rV�#��'�`�)��Byh�X��a���שҬ�ڶ��RW�/�<,��DM���';O|�V�OE�;�q:&�BwX��u� v-a��$:9�6�RIv��������my�(�+�*"c���=QJ��S�M��MԵ�_�S��i�򳽈}U8P��Hԫ+��u��ˆď䓻p��J��ڞ[���b�n�0Fb��*4��Â�S�}�1�Յި���|8ezTqZ&�r�w��#O�9��}tx]���'����B�i&��?�ݹm�x������:��_v��Gm�(�����	bO�>J5�cG�?��+�y����<�Y���t�Ϧ��|L������]$�=c��������{=���G�����CI�������5�L�X���R��7?�%�����?}J����p�}���?�㾊��i>�����������.0�ox��D����n���Ǎpm�N������{,4#���'縉�i$����I_�zR��v��I�d���r��x�0qcfr��${{��(����7�x�#����w��~�c�=�I��%���w�����w܏�ɫ���[~I��OO;v������<Q�T ���;�r��}u��������<��XK����~��`m�m3�Ϗy��ӕ�渆�޳�M��"�`纎k��DނO��?q'w&�� �Bo�q�4����ÿ�Z�~����f�?�i,<��/���צ�������{��$�|��9��f@�{�M�t����?n�q��W��œ,���67aF���x�s�pM�ӓU=���SJZ��E�qwɍ'�{Տ�j�����H�VM�;���Hva*�����t�w�j�ez�w�ח������=q�}                           p���,�	 � 