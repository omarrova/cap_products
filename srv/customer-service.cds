using {com.omrv as omrv} from '../db/schema';

service CustomerService {
    entity CustomerSrv as projection on omrv.customer;
}
